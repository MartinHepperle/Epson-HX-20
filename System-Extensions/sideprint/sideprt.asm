;
; Epson HX-20
;
; Sideways Printer Device
; By Elizabeth Wald
;
; Published in Personal Computer News (PCN)
; of February 11, 1984
;
; Typed in and adapted to A09 asembler syntax 
; by Martin Hepperle, 2024
;
; Notes:
; The NOPs seem to be mostly placeholders resulting
; from the original assembler programming tools
; running on the HX-20.

   ; HX-20: Hitachi 6301
   ; a09 options
   OPT H01
   OPT NCL

INITAB   EQU   $0078   ; address of initialize flags
BASTAB   EQU   $0134   ; sddress of start of application files == RMLTAB on start
CNDADR   EQU   $0136   ; address of program area
CNADR    EQU   $0138   ; address of save and condense routine
RMLTAB   EQU   $012C   ; last address in RAM + 1 == end of application files + 1
LNKTBL   EQU   $013C   ; address of application prgram link table
DCBTAB   EQU   $0657   ; address of device control block table
WARMST   EQU   $8004   ; address of BASIC warm start routine in ROM
ERROR    EQU   $8433   ; address of output error code routine
SOUND    EQU   $FF64   ; address of beep routine
LNPRNT   EQU   $FF94   ; print one line of characters
COLCNT   EQU   $FFD2
   
   ORG $0A40

   ; Check, that enough space exists to link
   ; in extended Basic. If space exists,
   ; then the program branches to
   ; L0A7D. Otherwise it generates a beep and
   ; branches to EXIT_2 to return to Basic.
   LDS #$04AF      ; stack pointer to I/O work area
   ; address INITAB indicates application program cold start.
   ; for each bit, 0: cold start 1: warm start
   ; bit 6: BASIC application programs
   ; bit 7: BASIC interpreter   
   TIM #$40,INITAB      ; test bit 6 of INITAB
   BEQ L0A50            ; branch, if BASIC interpreter cold start
   
   LDX CNADR            ; get address of BASIC work area save/condense routine ...
   JSR 0,X              ; and call it
   AIM #$BF,INITAB      ; clear bits 6 of INITAB

L0A50:
   BSR L0A52            ; leaves absolute address of L0A52 on stack
L0A52:
   PULA                 ; 
   PULB                 ; address to (D)
   ADDD #(EXTHOOK-L0A52)   ; #$00CE == distance to EXTHOOK
   STD  $6A             ; save at monitor work area M5: absolute address of EXTHOOK
   LDD  #$07A0          ; 1952d size of what? driver code from $0B20 to $0D61 = $0241
   STD  $68             ; save $07A0 at monitor work area M4: size?
   ADDD $6A             ; add absolute address to size
   STD  $6C             ; save at monitor work area M6: end address?
   
   
   ; --- top of RAM               <- RMLTAB
   ; ... BASIC extensions, if any
   ; --- top of BASIC files       <- BASTAB
   ; ... BASIC application files
   ; --- top of BASIC programs    <- CNADR
   ; ...
   LDD  RMLTAB          ; load address of end of RAM area
   STD  $62             ; -> src last byte
   LDD  BASTAB          ; load start address of BASIC application area
   STD  $60             ; -> src start
   SUBD $68             ; minus size
   STD  $64             ; -> destination
   XGDX                 ; to X
   CPX $6C              ; compare destination with end address
   BCC L0A7D
   
   ; not enough room
   LDD #$0605           ; 
   JSR SOUND            ; SOUND
   BRA EXIT_2
   
   ; copy all application files and BASIC programs
   ; down and copy extended BASIC into the space
   ; created at the top of memory
L0A7D:
   SEI
   STX BASTAB
   LDD CNDADR           ; address of program area
   SUBD $68             ; minus size ($07A0 was stored above)
   STD CNDADR           
   BSR CPYBLK           ; copy src -> dst

; 0A9A...0AB7
   ; initialise the 'JMP' instruction to link 
   ; the extended Basic into the interpreter
   ; (warm start hook)
   LDD $6A              ; source start
   STD $60              
   LDD $6C              ; source end
   STD $62              
   LDD $64              ; destination
   STD RMLTAB           
   BSR CPYBLK           ; copy src -> dst

   LDX BASTAB
   INX
   INX
   INX                  ; *(BASTAB) + 3

   ; search for RTS, free slot
L0AA0:
   LDAA 0,X
   CMPA #$39            ; RTS
   BEQ RTSHERE
   
   ; skip JMP address
   LDX 1,X     address
   DEX
   DEX
   DEX                  ; address - 3
   BRA  L0AA0           ; repeat

RTSHERE:
   LDAA #$7E            ; write "JMP"
   STAA 0,X             ; to (X)
   LDD  RMLTAB          
   ADDD #$0003          ; +3
   STD  1,X             ; write destination

; 0AB9
   ; Update the menu entries for the
   ; application files
   LDX  #LNKTBL   ; link table $013C...$013F
   LDAA 1,X   ; is the 2nd byte 'E'?
   CMPA #$45   ; ':'/'E'/FF/FF  'E' == end of link table
   BEQ  EXIT_1   ; ':'==no program, '0xBA'==program there
   
L0AC2:
   STX  $6E   ; save link table address (X) in monitor work area
   LDAA 1,X   ; byte 1 'A',...
   LDX  2,X   ; byte 2+3 = address of next header
   CPX  #$FFFF
   BEQ  EXIT_1   ; branch if end of link table
   
   TSTA      ; bit 7: 0=abs., 1=rel. address
   BMI  ISREL   ; link in X is relative address
   XGDX      ; move (X) to (D) for addition
   SUBD $68   ; make relative (size $07A0 was stored above)
   XGDX      ; rel. address is in (X)
ISREL:
   XGDX      ; save rel. address in (D)
   LDX $6E      ; restore (X) from monitor work area
   STD 2,X      ; copy rel address to link table
   TST 1,X      ; 
   BPL L0ADF   ; abs address
   ADDD $6E   ; make absolute
L0ADF:
   XGDX
   LDAA 1,X
   CMPA #$45   ; 'E'
   BEQ  EXIT_1
   
   TSTA      ; bit 7: 0=abs., 1=rel. address
   BMI  ISREL2   ; link is relative address
   LDD  4,X   ; 
   SUBD $68   ; make relative (size $07A0 was stored above)
   STD  4,X
ISREL2:
   BRA L0AC2   ; next entry

   ; Resets MEMSET to the value before the Basic
   ; loader program was run
EXIT_1:
   LDX BASTAB   ; BASIC starting address BASTAB=BSWTAD
   LDD $02CE   ; from monitor work area (saved there by BASIC loader program)
   STD $A,X    ; store (D) 10 bytes offset into BASIC?
EXIT_2:
   CLI
   CLRA
   LDX WARMST   ; BASIC warm start entry point
   JMP 0,X      ; jump to WARMST in BASIC ROM

;
; 8000 : BA 42 FF FF        ; 'B'  link header in BASIC ROM
; 8004 : 80 0C         
; 8006 :       FCB   "BASIC" == menu name
; 800B : 00         ;
; 800C : 7E B2 2F      jmp LB22F

; ---------------------
; block copy subroutine 
; copy bytes from src_beg to src_end
; $60=src_beg, $62=src_end, $64=dst
CPYBLK:
   LDX $60      ; get source address
   CPX $62      ; == end address?
   BEQ CPYDON   ; done
   LDAA 0,X   ; get to (A)
   INX      ; increment source address
   STX $60      ; store new source address
   LDX $64      ; get destination address
   STAA 0,X   ; store (A)
   INX      ; increment destination
   STX $64      ; store new destination address
   BRA CPYBLK   ; again
CPYDON:
   RTS

;
   NOP      ; why?
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   NOP
   
   ; initialize hook used to link in further extended Basics
EXTHOOK:
   RTS               ; placeholder for JSR
   FCB $00, $00      ; placeholder for address
   
   ; Device driver initialization, called on each warm start
EXTINIT:
   PSHX                    ; save
   BSR L0B26              ; leaves address of L0B26 on stack
L0B26:
   PULX            ; get absolute address

INITDRV:
   PSHX            ; save address
   XGDX
   ADDD #(NAME-L0B26)           ; offset = #$006A -> D = absolute address of DCB.NAME
   PSHB            ;
   PSHA            ; push abs. address of DCB
   PULX            ; drop address of DCB into X
   ADDD #(OPENDEV-NAME)           ; == #$0020 distance to OPEN
   STD  5,X         ; store abs. address of OPEN at DCB+5
   ADDD #(CLOSEDEV-OPENDEV)   ; == #$007C
   STD  7,X         ; store abs. address of CLOSE DCB+7
   ADDD #(WRITEDEV-CLOSEDEV)   ; == #$FFA0 (negative)
   STD  $B,X                   ; store abs. address of WRITE at DCB+11
   CLR  $13,X      ; internal flag
   XGDX            ; save DCB address in (D)
   LDX #(DCBTAB+7*2)   ; DCBTAB 0657 + 14d (KYBD: ... LPT0:)

NXTDCB:
   TST 0,X         ; loop over table
   BEQ L0B53      ; free slot
   INX            ; advance
   INX            ; to next slot
   CPX #(DCBTAB+2*16)   ; end of DCB table?
   BNE NXTDCB      ;

   PULX            ; drop address of L0B26
   PULX            ; drop return address?
   BRA EXTEXIT      ; error exit: no free DCB table slot
   
L0B53:
   STD 0,X         ; store DCB address in free slot
   PULA            ; 
   PULB            ; drop message address of L0B26
   PULX            ; 
   ADDD #(LOGON-INITDRV)   ; == $0038 make into absolute address
   XGDX
EXTEXIT;
   BRA EXTHOOK      ; just an RTS

LOGMSG   FCB $D8         ; 
LOGON   FCB "Extended Epson BASIC",$0D,$0A,"with SPT0: by E Wald",$0D,$0A,$00
   FCB $25,$2C,$FF,$8F
   
; Device Control Block
NAME   FCB   "SPT0"
IOMODE   FCB   $20
OPEN   FDB   $0000      ; these addresses are "funny"
CLOSE   FDB   $0000
INPUT   FDB   $8C70      ; an input routine?
OUTPUT   FDB   $0000      ; no output routine?
EOF   FDB   $8C70      ;
LOF   FDB   $8C70      ; all point to 8C70
INTERN   FCB   00,00,00,00   ; internal, $11,$12,$13,$14
            ; $13,X: open for output flag
            ; $14,X: row position
COL    FCB   00      ; $15,X: current column
MAXCOL   FCB   $50
PRINT   FCB   $0E
LASPRT   FCB   $46
CPL   FCB   $80
   FCB   $00,$00,$00,$00,$00,$00

FILMOD   EQU   $068A

; OPEN device
OPENDEV      LDAA FILMOD   ; read/write
      CMPA #$20   ; $20: output
      BEQ  OPENW
      LDAB #$33   ; error code 51d
      JMP  ERROR
      
OPENW      BSR  L0C20   ; get DCB address into (X)
      TST  $13,X   ; SIDEPRT internal flag 
      BMI  L0BC7   ; bit 7 set: return
      OIM  #$80,$13,X   ; set bit 7: device is open
      BRA  L0C19   ; print separator line
L0BC7      RTS
      
      FCB  $00

; WRITE one byte to device
NOTOPEN      BSR  OPENDEV
      PULA      ; restore character
            ; try again
WRITEDEV   BSR  L0C20   ; get DCB address into (X)
      PSHA      ; save character to write
      TST  $13,X   ; SIDEPRT internal flag
      BEQ  NOTOPEN   ; not opened: force open
      PULA      ; restore character
      CMPA #$0D
      BEQ  WRTCRLF
      CMPA #$0A
      BEQ  WRTCRLF
      CMPA #$20
      BCS WRTEXIT   ; character below $20: unprintable

      ; space or higher character
      PSHA      ; save character
      LDAA $14,X   ; row position
      LDAB #$50   ; 80d: one row length
      MUL      ; (D)=(A)*(B)
      PSHA      ; save
      LDAA $15,X   ; column
      ABA      ; + column
      TAB
      PULA      ; restore
      ADCA #$00   ; add carry
      PSHX      ; DCB address to stack
      TSX      ; SP -> X
      ADDD 0,X   ; add offset 
      ADDD #$01D0   ; offset to buffer 464d=16*29, DCB size = 26d
; offset 
; 0   0...15 bytes = row 0
; 15 ... row 1
; 30 ... row 2
;    ... row 79

      PSHB
      PSHA      ; destination address to stack
      TSX      ; SP -> X
      LDAA 4,X   ; get character
      LDX  0,X   ; get destination address
      STAA 0,X   ; insert character
      PULX      ; drop destination address
      PULX      ; 
      INS      ; drop
      INC  $15,X   ; increment column count 
      LDAB $15,X   ; get next column
      CMPB #$50   ; ==80d? end of line reached?
      BNE  WRTEXIT
      
WRTCRLF      CLR  $15,X   ; start new line in column 0
      CMPA #$0D   ; CR?
      BEQ  WRTEXIT
      
      INC  $14,X   ; increment row count
      LDAB $14,X
      CMPB #$10   ; ==16d? buffer full
      BCS  WRTEXIT
      
L0C17      BSR  PRTBUF   ; output buffer
L0C19      BSR  PRTSEP   ; print separator lines
      BSR  CLRBUF   ; prepare for next block
      
WRTEXIT      RTS

      FCB  $00,$00

; return the absolute address of the DCB in (X)
L0C20      BSR  L0C22   ; leaves address of L0C22 on stack
L0C22      PULX      ; drop address into X
      XGDX
      SUBD #(L0C22-NAME)   ; #$0092 == subtract distance to DCB.NAME
      XGDX
      RTS
      
      FCB  $00,$00,$00

; CLOSE device
CLOSEDEV   BSR  L0C20   ; get DCB address into (X)
      TST  $13,X   ;
      BEQ  CLOSDONE   ; return if buffer empty
      CLR  $13,X   ;
      TST  $14,X   ; row count == 0
      BNE  L0C17   ; output buffer if row>0
      TST  $15,X   ; column count == 0?
      BNE  L0C17   ; output buffer if column>0
CLOSDONE   RTS
      
      FCB  $00,$00,$00
      
; fill buffer with spaces
CLRBUF      BSR L0C20   ; get DCB address into (X)
      CLR $14,X   ; row count = 0
      CLR $15,X   ; column count = 0
      XGDX
      ADDD #$01D0   ; offset to buffer = 464d
      XGDX
      LDD  #$0500   ; count = 1280 = 80*16
L0C4E      PSHA      ; save
      LDAA #$20   ; space
      STAA 0,X   ; store ' '
      INX      ; increment address
      PULA      ; restore
      SUBD #$0001   ; decrement count
      BNE L0C4E
      RTS
      
      ; fills the printer buffer with a character      
PRTSEP      PSHX
      PSHB
      PSHA
      LDAA #$85   ; horizontal line character
      BSR FILLINE
      JSR LNPRNT   ; print one line
      LDAA #$20   ; spaces
      BSR FILLINE
      PULA
      PULB
      PULX
      RTS
      
FILLINE      LDAB #$18   ; 24d
      LDX COLCNT   ; address of microprinter column
      INX
      PSHX
NXTCOL      STAA 0,X   ; store at microprinter column
      INX
      DECB      ;
      BNE NXTCOL
      PULX
      RTS

      ; prints a text block sideways down the paper
PRTBUF      BSR L0C20   ; get DCB address into (X)
      XGDX
      ADDD #$01D0   ; offset to buffer = 464d
      STD  $6E
      ADDD #$0500
      STD  $6C
      CLRB
L0C8A      PSHB
      CLRB
L0C8C      PULA
      PSHA
      PSHB
      BSR  L0CF8
      LDX  $6C
      ABX
      LDAA $0190
      STAA 0,X
      LDAA $0191
      STAA $10,X
      LDAA $0192
      STAA $20,X
      LDAA $0193
      STAA $30,X
      LDAA $0194
      STAA $40,X
      LDAA $0195
      STAA $50,X
      PULB
      INCB
      CMPB #$10
      BNE L0C8C
      CLRB
L0CB9      PSHB
      LDAA #$10
      MUL
      ADDD $6C
      ADDD #$000E
      LDX  $FFD2
      INX
      PSHX
      PSHX
      XGDX
      BSR  CVT16_24   ; 0
      BSR  CVT16_24
      BSR  CVT16_24
      BSR  CVT16_24
      BSR  CVT16_24
      BSR  CVT16_24
      BSR  CVT16_24
      BSR  CVT16_24   ; 7
      PULX
      PULX
      JSR $FF91
      PULB
      BCS L0CED
      INCB
      CMPB #$06
      BNE  L0CB9
      PULB
      INCB
      CMPB #$50
      BNE L0C8A
      RTS
      
L0CED      LDAB #$35   ; error code 53d I/O error
      INS
      JMP  ERROR

      FCB  $00,$00,$00,$00,$00

      ; read a character from the the buffer
      ; and obtain the corresponding dot pattern
L0CF8      PSHB
      PSHA
      LDX  $6E
      PSHX
      TSX
      LDAA 3,X
      LDAB #$50   ; row length
      MUL
      ADDB 2,X
      ADCA #$00
      ADDD 0,X
      XGDX
      LDAA 0,X
      PULX
      LDX #$0190
      JSR $FF67
      PULA
      PULB
      RTS
      
      FCB  $00,$00
   
      ; convert 16 bytes of dot data to the
      ; 24 bytes required by the printer subroutine
      ; 16*8 dots = 128 dots
CVT16_24   PSHX      ; SP+2
      LDAA 0,X   ; (A) 76543210
      PSHA      ; SP+4
      LDAB 1,X   ; (B) 76543210
      PSHB      ; SP+6
      TSX      ; SP->X
      LSRB      ; (B) -7654321
      LSRB      ; (B) --765432
      LSRB      ; (B) ---76543
      LDX  6,X   ; destination
      STAB 0,X   ; ---76543........
      PULB      ; (B) 76543210
      ASLB      ; (B) 6543210-
      ROLA      ; (A) 65432107
      ROLB      ; (B) 543210-6
      ROLA      ; (A) 54321076
      ROLB      ; (B) 43210-65
      STAB 1,X   ; ........43210-65
      PULA      ; (A) 76543210
      STAA 2,X   ; 
      BSR L0D40
      BSR L0D40
      BSR L0D40
      XGDX
      TSX      ; SP->X
      STD  4,X
      PULX
      DEX
      DEX
      RTS
      
L0D40      LDAB 0,X   ; load (B)
      LDAA #$20   ; 00100000 bit 5, loop is executed 6 times
      STAA $6B   ; save to microcassette buffer  
      CLRA      ; (A) = 0
L0D47      LSRB      ; 
      BCC L0D4C   ; skip if bit 7 == 0

      ORAA $6B   ; mask bit

L0D4C      LSR  $6B   ; 00010000, 00001000, 00000100, 00000010, 00000001
      BCC L0D47   ; 
      STAA 0,X   ; (A)
      INX      ; next byte
      RTS
      
      ; appended to binary match sideprt.bin
      FCB $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$41
   END
   