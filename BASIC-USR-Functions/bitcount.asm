; ---------------------------------------------------------------
; a09 bitcount.asm -C -Lbitcount.lst
; python LST2BAS.py bitcount.lst > bitcount.bas
; or, with DEBUG_INT defined
; a09 bitcount.asm -Lbitcount.lst -Sbitcount.srec
; sim6301 bitcount.srec
;
; Epson HX-20
;
; This is an example which embeds two functions
; in a single machine language module.
; These functions can be used as USR functions from BASIC.
;
; Martin Hepperle, 2025
; ---------------------------------------------------------------

        ; HX-20: Hitachi 6301
        OPT H01

        ; no line length limit
        OPT NCL

; -------------------------
; optionally define this symbol for debugging with sim6301
; DEBUG_INT TEXT    ; optional: set DEBUG_INT flag for sim6301
; can also use a symbol file of the form
; 0A40 ENTRY
; ... more address/symbol pairs
; -------------------------


; BASIC floating point accumulator
FPTYP   EQU  $0085    ; 2 bytes: type of number in FPACC
FPACC   EQU  $00D5    ; first byte of floating point accumulator


        ; load this module below BASIC program
        ; use MEMSET &H0A88
        ORG     $0A40

;
; Parameter passing for USR functions:
; Register A contains 2 if the parameter is an integer
; For integer variables, register X points to the 16-bit
; integer N% in the floatingpoint accumulator:
;    X,0 -> n.c.
;    X,1    n.c.
;    X,2    high byte of N%
;    X,3    low byte of N%
; (X contains the address FPACC)
;
; Return the bit count or 255 if no integer was given.
;
; The integer return value is stored in FPACC and its 
; type in FPTYP.
;
; All functions destroy A and B, these are saved when BASIC calls
; the USR functions.
; ---------------------------------------------------------------

; Jump table with functions, entries are 2 bytes apart.
; This simplifes the definition of multiple USR functions
; in a single file, but slighty slows down each call.
        BRA COUNTBITS    ; DEF USR1=&H0A40 : N%=USR1(I%) count bits in i%
        BRA LROTBITS     ; DEF USR2=&H0A42 : N%=USR1(I%) rotate i% left by 1

; =================================================================
; A USR function for rotating the bits in its integer parameter N% left by 1.
; If the parameter is not an integer, a value of 0 is returned.
; Performs no simple left shift where the MSB would be lost in carryland,
; but a circular rotation where the leftmost bit is rotated into bit 0.
;
; ------
;   I%=USR1(-32757)  10000000'00000001 -> 00000000'00000011
;   ?I%
;   3
; ------
;
LROTBITS:
   IFD DEBUG_INT
        ; -------------------------
        ; parameter setup for debugging with sim6301
        ; integer parameter
        LDD  #$8000   ; integer number
        STAA FPACC+2  ; high byte of integer
        STAB FPACC+3  ; low byte of integer
        LDAA #$2      ; integer type for FPTYP, leave in A for BASIC
        STAA FPTYP    ; type of data in FPACC
        LDX  #FPACC   ; address of FPACC
        ; -------------------------
   ENDIF

        CMPA #$02     ; do we have an integer?
        BNE  ERRBITS  ; no: return error value 0
  
        LDAA $2,X     ; get high byte of integer -> A
        LDAB $3,X     ; get low byte of integer -> B
        ASLB          ; C <- shift B left <- 0
        ROLA          ; C <- shift A left <- C
        BCC NOBIT0    ; no carry
        ; set bit 0
        INCB
NOBIT0:
        ; fall through to RETINT
; ---------------------------------------------------------------
RETINT:
; Common "return integer in (A,B) resp (D)" exit point.
; Store 16-bit integer in FPACC+2,3
; FPTYP is set in case the parameter was no integer.
RETINT:
        STAA FPACC+2  ; high byte
        STAB FPACC+3  ; low byte
        LDAA #$02     ; set return data type: integer
        STAA FPTYP    ; type of data in FPACC

        RTS
; ---------------------------------------------------------------
ERRBITS:
        CLRA          ; integer 0
        CLRB
        BRA RETINT    ; return (A,B)

; =================================================================
; A USR function for counting the bits in its integer parameter N%.
; If the parameter is not an integer, a value of 255 is returned.
;
; ------
;   I%=USR1(1+2+32)
;   ?I%
;   3
; ------
;;;;;COUNTBITS:
;;;;;        CLR  BITS     ; prepare...
;;;;;        DEC  BITS     ; ...error return: 255
;;;;;
;;;;;; using a break point:
;;;;;; BREAK1: FCB     $00   ; TRAP into MONITOR for debugging
;;;;;; This byte is at address A46.
;;;;;; Inspect register A
;;;;;; GA47 continues and returns.
;;;;;; Use GA47,A47 to execute the next instruction only.
;;;;;; Use GA47,A48 to execute the next two instructions, etc.
;;;;;; Use D to inspect memory, e.g. CNTBITS.
;;;;;; B aborts to BASIC without continuing.
;;;;;
;;;;;        CMPA #$02     ; do we have an integer?
;;;;;        BNE  ERRCOUNT ; no: return error value 255
;;;;;  
;;;;;        CLR  BITS     ; start over
;;;;;
;;;;;        LDAA $3,X     ; get low byte of integer -> A
;;;;;        JSR  CNTBITS   ; count bits in A
;;;;;        
;;;;;        LDAA $2,X     ; get high byte of integer -> A
;;;;;        JSR  CNTBITS   ; count bits in A
;;;;;
;;;;;ERRCOUNT:   
;;;;;        ; return BITS [0..16] or 255 if no integer was given  
;;;;;        CLRA          ; zero upperbyte
;;;;;        LDAB BITS     ; get bit count
;;;;;        BRA RETINT    ; return integer in (A,B)
;;;;;; ---------------------------------------------------------------
;;;;;; --- subroutine: count bits in A ---
;;;;;CNTBITS:
;;;;;        LDAB    #$8      ; loop count
;;;;;
;;;;;NEXT:   ASRA             ; shift bit 0 TO CARRY
;;;;;        BCC     NOPE     ; 0: carry clear
;;;;;        INC     BITS     ; add one
;;;;;NOPE:
;;;;;        DECB             ; decrement bit count
;;;;;        BNE     NEXT     ; next bit
;;;;;        RTS
;;;;;; ---
;;;;;        
;;;;;BITS:   FCB     $FF      ; collects bit count

;
: Alternative, keeping the counter in (B) and not in RAM
;
COUNTBITS:
        CLRB    ; prepare...
        DECB    ; ...error return: 255

        CMPA #$02     ; do we have an integer?
        BNE  STOREB   ; no: return error value 255

        CLRB          ; zero bit count
  
        LDAA $2,X     ; get high byte of integer -> A
        CLR  $2,X     ; clear return value
        BRA NEXTBIT   ; jump to first pass
AGAIN:
        CLR  $3,X     ; clear to terminate second pass
NEXTBIT:
        ASLA          ; C <- (A) <- 0
        BCC NOBIT     ; skip and keep Z-flag undisturbed
        INCB          : add one, Z-flag=false
NOBIT:
        BNE NEXTBIT   ; jif any 1-bits left
        LDAA $3,X     ; get low byte of integer -> A, affects Z-flag
        BNE AGAIN     ; second pass if A has any bits set

STOREB:               ; return (B) as a BASIC integer
        CLRA          ; clear high byte
        BRA RETINT
; ---

MEMSET  *                ; this symbol defines the parameter for MEMSET

        END
