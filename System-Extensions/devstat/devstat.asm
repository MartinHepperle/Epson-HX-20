;
; A device driver for the Epson HX-20
;
; a09 devstat.asm -ldevstat.lst
; python LST2BAS.py devstat.lst > devstat.bas
;
; M. Hepperle 2024
;
        ; HX-20: Hitachi 6301
        ; a09 options
        OPT H01
        OPT NCL
;
; Implements a simple device "STAT:" which counts
; the occurrence of bytes written to it. The byte counters are 16-bit wide.
; Reading from the device returns the occurances in form of high/low byte
; pairs until all 256 byte pairs have been read.
; The LOF() function returns always 2 (2 bytes to read).
; The EOF() function returns 0 if there is something to read, -1 otherwise.
;
; Example
;
; 10 REM --- Epson HX-20      ---
; 20 REM --- M. Hepperle 2024 ---
; 21 REM Installs a device "STAT:".
; 22 REM Writing to it counts the 
; 23 REM number of occurrances of
; 24 REM each character code (0...255).
; 25 REM Reading returns 256*2 bytes
; 26 REM (high,low) which represent the
; 27 REM accumulated number of each character.
; 28 REM One can use LIST "STAT:" to count
; 29 REM how often each character occurs.
; 30 REM --- adjust BASIC starting address
; 40 MEMSET &HCB3
; 50 REM --- load the code bytes
; 60 GOSUB 350
; 70 REM --- install driver
; 80 GOSUB 450
; 90 REM --- application example
; 100 OPEN "O",#1,"STAT:"
; 110 FOR I%=1 TO 300
; 120 PRINT#1,CHR$(0)+"AAABBC"
; 130 NEXT I%
; 140 CLOSE #1
; 145 REM --- entry e.g. after LIST "STAT:"
; 150 PRINT "Finding maximum..."
; 160 MX=0
; 170 OPEN "I",#1,"STAT:"
; 180 FOR I%=0 TO 255
; 190  H$=INPUT$(1,#1) : L$=INPUT$(1,#1)
; 200  Y=ASC(H$)*256+ASC(L$)
; 210  IF Y>MX THEN MX=Y
; 220 NEXT I%
; 230 CLOSE #1
; 240 GCLS
; 250 OPEN "I",#1,"STAT:"
; 260 FOR I%=0 TO 127
; 270  H$=INPUT$(1,#1) : L$=INPUT$(1,#1)
; 280  Y%=31*(1-(ASC(H$)*256+ASC(L$))/MX)
; 290  LINE(I%,31)-(I%,Y%),PSET
; 300 NEXT I%
; 310 CLOSE #1
; 320 SOUND 33,2
; 330 C$=INPUT$(1)
; 340 END
; 350 REM --- Hex Code Loader ---
; 360 N%=0
; 370 READ C$
; 380 IF C$="DONE" THEN 430
; 390 N%=N%+1 : IF N%=8 THEN PRINT "."; : N%=0
; 400 C%=VAL("&H"+C$)
; 410 IF LEN(C$)=4 THEN A%=C% : GOTO 370
; 420 POKE A%,C% : A%=A%+1 : GOTO 370
; 430 PRINT
; 440 RETURN
; 450 REM --- Device Installer ---
; 460 DCBTAB%=&H0657
; 470 FOR A%=DCBTAB% TO DCBTAB%+30 STEP 2
; 480 C%=PEEK(A%)*256+PEEK(A%+1)
; 490 IF C%=&H0A40 THEN GOTO 550
; 500 IF C%=&H0000 THEN GOTO 520
; 510 NEXT A%
; 520 IF A%>DCBTAB%+28 THEN GOTO 570
; 530 POKE A%,&H0A : REM HIGH
; 540 POKE A%+1,&H40 : REM LOW
; 550 PRINT "STAT: @";A%;"installed"
; 560 RETURN
; 570 PRINT "Cannot install STAT:"
; 580 STOP
; 2141 DATA 0A40,53,54,41,54,30,0A,5A,0A,78,0A,79,0A,8F,0A,9F,0A,AB,00
; 2142 DATA 00,00,00,00,00,14,00,80,B6,06,8A,81,10,27,10,CE,0A,B1,86,FF
; 2143 DATA 6F,00,6F,01,08,08,4A,81,FF,26,F5,CE,0A,B1,FF,0C,B1,39,39,7F
; 2144 DATA 00,F5,FE,0C,B1,8C,0C,B1,27,07,A6,00,08,FF,0C,B1,39,7A,00,F5
; 2145 DATA 39,36,33,4F,05,C3,0A,B1,18,EC,00,F3,0A,AF,ED,00,39,5F,FE,0C
; 2146 DATA B1,8C,0C,B1,27,01,39,5A,39,CC,00,02,39,00,01,DONE
;

;
; Insert me below BASIC (BASIC requires appropriate MEMSET &HA40 + sizeof this)
; (a probably better solution would be to place the binary above BASIC and move 
;  all BASIC files down)

             ORG   $0A40

EOFLG         EQU   $00F5       ; EOF flag (system ROM A000-BFFF)
ASCFLAG       EQU   $68C        ; 0=binary, 1=ASCII
OPENMODE      EQU   $068A
MODE_INPUT    EQU   $10
MODE_OUTPUT   EQU   $20

; ------------------------------
; Device Control Block
DCB:    FCB     "STAT"          ; 4 character name
        FCB     $30             ; I/O mode: $01: r, $20: w, $30: r/w
        FDB     OPENDEV         ; OPEN routine
        FDB     CLOSEDEV        ; CLOSE routine
        FDB     READDEV         ; READ routine
        FDB     WRITEDEV        ; WRITE routine
        FDB     EOFDEV          ; EOF routine
        FDB     LOFDEV          ; LOF routine
DEVBUF: FCB     $00,$00,$00,$00 ; used for device purposes
COLPOS: FCB     $00             ; current column position, see POS(#)
MAXCOL: FCB     $00             ; max. column: inf.
PRTTAB: FCB     $14             ; print zone width of “,” separated PRINT output
LSTTAB: FCB     $00             ; last print zone on line
WIDTH:  FCB     $80             ; WIDTH support: $00: yes, $80: no
; ------------------------------

; -----------------------------------------------------------
; called by OPEN
; OPEN "I",#1,"STAT:"
; OPEN "O",#1,"STAT:"
OPENDEV:
        LDAA    OPENMODE        ; opened for "O" or "I"?
        CMPA    #MODE_INPUT
        BEQ     OPEN_DONE
     
        ; file opened for output
        
        ; zero array of 16-bit counters
        LDX     #ACCU           ; (X) = address of ACCU
        LDAA    #255            ; (A) = count
CLEAR_1:
        CLR     0,X             ; zero
        CLR     1,X             ; zero
        INX                     ; increment pointer
        INX                     ; increment pointer
        DECA                    ; count--
        CMPA    #$FF            ; done?
        BNE     CLEAR_1         ; more?
                             
OPEN_DONE:                    
        LDX     #ACCU           ; start of array...
        STX     IDX             ; ...to pointer

        RTS

; -----------------------------------------------------------
; called by CLOSE
; CLOSE #1
CLOSEDEV:
        ; no action
        RTS

; -----------------------------------------------------------
; called e.g. by INPUT$
; C$=INPUT$(n,#1)
; read one byte from device
; return byte in (A) or set EOFLAG to $FF on EOF
READDEV:

        CLR     EOFLG           ; not at EOF: $00

        LDX     IDX             ; (X) = pointer to array element to read
        CPX     #IDX            ; IDX immediately follows ACCU array
        BEQ     AT_EOF          ; jif end of array reached

NOT_EOF:
        LDAA    0,X             ; (A) = 8-bit value
        INX
        STX     IDX             ; increment pointer to next byte
        RTS
   
AT_EOF:   
        DEC     EOFLG           ; EOF: $FF   
        RTS

; -----------------------------------------------------------
; called multiple times e.g. by PRINT#
; PRINT# 1,"ABC"
; write one byte to device
; (A) byte to write
WRITEDEV:

        ; convert byte into 16-bit offset
        PSHA                    ; push (A)   
        PULB                    ; pop to (B)
        CLRA                    ; (A) high = 0, (B) low
        ASLD                    ; * 2 -> 16-bit offset into ACCU
                                
        ADDD    #ACCU           ; (D) = ACCU+(D) = address of 16-bit cell
        XGDX                    ; (X) <> (D)     (X) = idx
                                
        LDD     0,X             ; get current 16-bit value from ACCU[idx]
        ADDD    ONE             ; increment 16-bit value
        STD     0,X             ; store new 16-bit value in ACCU[idx]

        RTS

; -----------------------------------------------------------
; called e.g. by EOF(1)
; return in (B) $FF if EOF, else $00
EOFDEV:
        CLRB                    ; not at EOF
        LDX     IDX             ; (X) = address to read
        CPX     #IDX            ; end of array reached?
        BEQ     EOF_EOF   
        RTS
EOF_EOF:
        DECB                    ; EOF
        RTS
; -----------------------------------------------------------
; called e.g. by LOF(1)
; return in (D) # of bytes in buffer
LOFDEV:
        LDD     #$0002          ; 
        RTS

; -----------------------------------------------------------
; the I/O buffer at the end, not necessary to hex-load these trailing bytes
ONE:    FCB  $00,$01            ; 16-bit ONE for addition
ACCU:   FILL $00,512            ; accumulator: 256 16-bit words 
IDX:    FCB  $00,$00            ; index for reading, behind buffer
MEMSET: $*                      ; used for MEMSET

        END
