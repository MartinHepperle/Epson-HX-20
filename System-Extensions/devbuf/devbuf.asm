; a09 device.asm -ldevice.lst
; python LST2BAS.py device.lst > device.bas

        ; HX-20: Hitachi 6301
        OPT H01
        OPT NCL

; insert below BASIC
        ORG     $0A40

;
; A device driver skeleton for the Epson HX-20
;
; Implements a simple device "BUF0:" which stores
; all bytes written to it in a ring buffer.
; Reading from the device returns the bytes written until
; the buffer is empty.
; The LOF() function returns the amount of data currently in the buffer.
; The EOF() function returns 0 if there is something in the buffer, -1 otherwise.
;
; Example
;
; 10 REM --- Epson HX-20      ---
; 20 REM --- M. Hepperle 2024 ---
; 30 REM --- adjust BASIC starting address
; 40 MEMSET &HAF8;
; 50 REM --- load the device "BUF0"
; 60 GOSUB 350
; 70 REM --- application example
; 80 OPEN "O",#1,"BUF0:"
; 90 PRINT #1,"123";
; 100 PRINT "POS(1)=";POS(1)
; 110 PRINT #1,"ABC"
; 120 PRINT #1,"abc";
; 130 PRINT "POS(1)=";POS(1)
; 140 CLOSE #1
; 150 ON ERROR GOTO 240
; 160 OPEN "I",#1,"BUF0:"
; 170 PRINT "Buffer size=";LOF(1)
; 180 FOR I%=1 TO 100
; 190  C$=INPUT$(1,#1)
; 200  IF ASC(C$)=13 THEN C$="CR"
; 210  IF ASC(C$)=10 THEN C$="LF"
; 220  PRINT "/";C$;
; 230 NEXT I%
; 240 CLOSE #1
; 250 PRINT"/"
; 260 PRINT "UNLINK BUF0:"
; 270 INPUT "Y/N";YN$
; 280 IF YN$<>"Y" THEN GOTO 330
; 290 IF A%=0 THEN GOTO 330
; 300 POKE A%,0
; 310 POKE A%+1,0
; 320 PRINT "BUF0: at";A%;"removed"
; 330 END
; 340 REM --- Hex Code Loader  ---
; 350 N%=0
; 360 READ C$
; 380 IF C$="DONE" THEN 430
; 390 N%=N%+1 : IF N%=8 THEN PRINT "."; : N%=0
; 400 C%=VAL("&H"+C$)
; 410 IF LEN(C$)=4 THEN A%=C% : GOTO 360
; 420 POKE A%,C% : A%=A%+1 : GOTO 360
; 430 PRINT
; 440 REM install device control block in DCB table
; 450 DCBTAB%=&H0657
; 460 FOR A%=DCBTAB% TO DCBTAB%+30 STEP 2
; 470  C%=PEEK(A%)*256+PEEK(A%+1)
; 480  IF C%=&HA40 THEN GOTO 540
; 490  IF C%=&H000 THEN GOTO 520
; 500 NEXT A%
; 510 IF A%>DCBTAB%+28 THEN GOTO 560 : REM ERROR
; 520 POKE A%,&H0A : REM HIGH
; 530 POKE A%+1,&H40 : REM LOW
; 540 PRINT "BUF0: at";A%;"added"
; 550 RETURN
; 560 PRINT "Cannot install BUF0:"
; 570 STOP
; 580 DATA 0A40,42,55,46,30,30,0A,5E,0A,5F,0A,60,0A,7C,0A,A0,0A,AC,00
; 590 DATA 00,00,00,00,00,14,00,80,0A,B8,0A,B8,39,39,FE,0A,5A,BC,0A,5C
; 600 DATA 27,0F,A6,00,08,8C,0A,F8,26,03,CE,0A,B8,FF,0A,5A,39,86,FF,97
; 610 DATA F5,39,5F,D7,F5,FE,0A,5C,A7,00,08,8C,0A,F8,26,03,CE,0A,B8,FF
; 620 DATA 0A,5C,81,0D,27,08,81,0A,27,04,7C,0A,55,39,7F,0A,55,39,5F,FE
; 630 DATA 0A,5A,BC,0A,5C,27,01,39,5A,39,FC,0A,5C,B3,0A,5A,2A,03,C3,00
; 640 DATA 40,39,DONE
; 650 REM --- END

; EOFLG   EQU     $00F8           ; EOF flag (Epson manual)
EOFLG   EQU     $00F5           ; EOF flag (J. Wald and system ROM A000-BFFF)

; ------------------------------
; Device Control Block
DCB:    FCB     "BUF0"          ; 4 character name
        FCB     $30             ; I/O mode: $01: r, $20: w, $30: r/w
        FDB     OPENDEV         ; OPEN routine
        FDB     CLOSEDEV        ; CLOSE routine
        FDB     READDEV         ; READ routine
        FDB     WRITEDEV        ; WRITE routine
        FDB     EOFDEV          ; EOF routine
        FDB     LOFDEV          ; LOF routine
DEVBUF: FCB     $00,$00,$00,$00 ; for device purposes
COLPOS: FCB     $00             ; current column position, see POS(#)
MAXCOL: FCB     $00             ; max. column: inf.
PRTTAB: FCB     $14             ; print zone width of “,” separated PRINT output
LSTTAB: FCB     $00             ; last print zone on line
WIDTH:  FCB     $80             ; WIDTH support: $00: yes, $80: no
; ------------------------------
; max. 64 bytes
READPT  FDB     BUFFER
WRITPT  FDB     BUFFER

; -----------------------------------------------------------
; called by OPEN
; OPEN "I",#1,"BUF0:"
; OPEN "O",#1,"BUF0:"
OPENDEV
        ; no action
        RTS

; -----------------------------------------------------------
; called by CLOSE
; CLOSE #1
CLOSEDEV
        ; no action
        RTS

; -----------------------------------------------------------
; called e.g. by INPUT$
; C$=INPUT$(n,#1)
; read one byte from device
; return byte in (A) or set EOFLAG to $FF on EOF
READDEV
        LDX     READPT          ; get read address
        CPX     WRITPT          ; compare with write position
        BEQ     READ_EOF        ; buffer is empty
        
        LDAA    ,X             ; get byte from buffer
        INX                     ; increment pointer
        CPX     #BUFEND         ; get address
        BNE     READ_1          ; o.k.
        ; wrap
        LDX     #BUFFER         ; back to start
READ_1
        STX     READPT          ; for next read

        RTS

READ_EOF
        LDAA    #$FF            ; EOF: $FF
        STAA    EOFLG           ;
        
        RTS

; -----------------------------------------------------------
; called e.g. by PRINT#
; PRINT# 1,"ABC"
; write one byte to device
; (A) byte to write
WRITEDEV
        CLRB                    ; not at EOF: $00
        STAB    EOFLG

        LDX     WRITPT          ; get current write address
        STAA    ,X              ; store byte
        INX
        CPX     #BUFEND         ; get address
        BNE     WRITE_1

        ;CPX     READPT          ; collision?
        ;BEQ     OOPS            ; would be fatal
	
        ; buffer overflow: wrap
        LDX     #BUFFER         ; get start address

WRITE_1
        STX     WRITPT          ; for next write
        
	; increment or reset POS
        CMPA    #$0D
        BEQ     ZERPOS
        
	CMPA    #$0A
        BEQ     ZERPOS
	
        INC     COLPOS  ; increment column index
        RTS

ZERPOS  CLR     COLPOS  ; reset column index
        RTS

; -----------------------------------------------------------
; called e.g. by EOF(1)
EOFDEV
        CLRB                    ; not at EOF
        LDX     READPT          ; get read address
        CPX     WRITPT          ; compare with write position
        BEQ     EOF             ; buffer is empty
        RTS
EOF
        DECB                    ; return $FF EOF flag
        RTS

; -----------------------------------------------------------
; called e.g. by LOF(1)
; return # of bytes in buffer

;  [.ABCDE.].      ABCDE not wrapped
;  [1234567]8      E=end,   behind buffer
;  [BR....W]E      B=begin, buffer 
;   W>R: LOF = (W-R) = (7-2) = 5
;
;  [E..ABCD].      ABCDE wrapped around
;  [1234567]8      W write pointer
;  [BW.R...]E      R read pointer
;   R>W: LOF = (E-R)+(W-B) = (8-4)+(2-1) =  4 + 1 = 5
;            = (W-R)+(E-B) = (2-4)+(8-1) = -2 + 7 = 5
;               W-R is negative 
LOFDEV
        LDD     WRITPT          ; get write address
        SUBD    READPT          ; subtract read address
        BPL     LOF_1           ; jif positive, else wrap
        ADDD    #(BUFEND-BUFFER)
LOF_1   
        RTS

; -----------------------------------------------------------
; the I/O buffer at the end, not necessary to hex-load these trailing bytes
BUFFER  FILL $00,64     ; buffer
BUFEND                  ; behind buffer, first free byte for BASIC
MEMSET  $*              ; same as BUFEND, used for MEMSET

        END
