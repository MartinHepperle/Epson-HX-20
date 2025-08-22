; ---------------------------------------------------------------
; for BASIC
; a09 stringrev.asm -Lstringrev.lst
; python LST2BAS.py stringrev.lst > stringrev.bas
;
; or for debugging
; a09 stringrev.asm  -DDEBUG_STR -Lstringrev.lst -Sstringrev.srec
; sim6301 stringrev.srec
;
; Epson HX-20
;
; This is an example which embeds one functions
; in a single machine language module.
; This functions can be used as a USR function from BASIC.
;
; Martin Hepperle, 2025
; ---------------------------------------------------------------

        ; HX-20: Hitachi 6301
        OPT H01

        ; no line length limit
        OPT NCL

        ; load this module below BASIC program
        ; use MEMSET &H0A79
        ORG     $0A40

; -------------------------
; optionally define this symbol for debugging with sim6301
;DEBUG_STR TEXT    ; set DEBUG_STR flag for debugging with sim6301
; can also use a symbol file of the form
; 0A40 ENTRY
; ... more address/symbol pairs
;
; -------------------------

;
; String parameter passing for USR functions:
; Register A contains 3 if the parameter is a string
; Register X points to the string descruptor:
;    X,0 -> length
;    X,1    high byte of address in string space
;    X,2    low byte of address in string space
;
; ---------------------------------------------------------------

; =================================================================
; A USR function for reversing the characters in a string S$.
; If the parameter is not a string, nothing is changed.
;
; Note that the string is modified in situ, no copy is produced.
; This means that literal strings in the BASIC program text will
; be modified. Listing such a program will show reversed
; characters after each run.
; Usually, strings to be reversed are created at run time, so that
; this feature is of no concern.
; ------
; LIST
;   10 PRINT USR1("ABC")
; RUN
;   CBA
; LIST
;   10 PRINT USR1("CBA")
; ------
; If you do not want your BASIC text to be modified, force
; the string to the dynamic string area by applying a string 
; operation like concatenating a zero length string to it.
; This will create a copy of the string in string space.
; ------
; LIST
;   10 S$="ABC"+""
;   20 PRINT USR1(S$)
; RUN
;   CBA
; LIST
;   10 S$="ABC"+""
;   20 PRINT USR1(S$)
; ------


; -------------------------
   IFD DEBUG_STR
        ; parameter setup for debugging with sim6301
        ; string parameter
        LDAA #$3        ; string type
        LDX  #STRDESC   ; address of string descriptor
   ENDIF
; -------------------------

REVSTR:
        CMPA #$03       ; do we have a string?
        BNE  EXITSUB    ; no: return without changing anything

        LDAB $0,X       ; get length of string (0..255) to B

        LDX  $1,X       ; get start address of string to X
        STX  HEAD       ; pHead = address of first character
        
        ; calculate pTail = pHead + length in A,B
        LDAA HEAD     ; A            high byte of address
                      ; B = length from above
        ADDB HEAD+1   ; B = length + low byte of address
        BCC  NOCARRY
        INCA          ; adjust high byte of address pTail
NOCARRY:
        ; A,B has address of one behind string
        XGDX            ; X = pTail
                        ; keep this tail pointer always in X
                        ; only head pointer will be maintained in RAM
  
        ; loop over half of the string
NEXT:
        ; decrement tail pointer
        DEX             ; pTail--

        CPX  HEAD       ; pTail <= pHead ?    (X - HEAD) TAIL-HEAD < 0
;     FCB 0 ; break
         BMI  EXITSUB    ; done                     X < HEAD    
;        BLE  EXITSUB    ; done                     X <= HEAD    
;        BEQ  EXITSUB    ; done               even: X == HEAD  set Z
;        BMI  EXITSUB    ; done               odd:  X < HEAD   set N 
;        BGE  EXITSUB    ; done               odd:  X < HEAD   set N 
;
; ABC odd # of characters
; h t   swap
; h=t   swap center character, unnecessary, but o.k.
; t h < 0: stop
;
; ABCD even # of characters
; h  t  swap
;  ht   swap
;  th   < 0:  stop
 ; 27                    BEQ   X == HEAD =0 -> C=D0
 ; 2B                    BMI   X < HEAD  <0 -> C=D1
 ; 2C                    BGE   X > HEAD  >0 -> C=D0
 ; 2F                    BLE   0000 0000
 ;                                X HEAD        X-HEAD
 ;                             1235 1234      D0  > 0 continue 
 ;                             1233 1234      D1  < 0 stop
 ;                             1234 1234      D0 == 0 stop
 ;                             
 
        ; swap the two characters *pHead and *pTail
        ; get tail character to B
        LDAB $0,X       ; B = *pTail

        PSHX            ; save pTail
        ; get head character to A
        LDX  HEAD       ; pHead
        LDAA $0,X       ; A = *pHead
        ; replace it in string by the tail character
        STAB $0,X       ; *pHead = B

        ; increment HEAD pointer
        INC  HEAD+1     ; pHead++
        BCC  NOCARRY2
        INC  HEAD       ; pHead++
NOCARRY2:
        PULX            ; restore pTail

        ; replace tail character in string by head character
        STAA $0,X       ; *pTail = A
  
        BRA  NEXT       ; loop for next character pair swap
EXITSUB:
        RTS

; -------------------------
HEAD    FCB  0,0

; -------------------------
   IFD DEBUG_STR
        ; test data for debugging with sim6301
STRDESC:
        FCB $4        ; string length
        FDB STRSPACE  ; 16-bit address of string in string space
STRSPACE: 
        FCC 'ABCD'     ; string in string space
   ENDIF
; -------------------------
MEMSET  *                ; this symbol defines the parameter for MEMSET in the listing

        END
