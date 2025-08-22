; -------------------------------------------------------
; Equates for the Epson HX-20 system
; Typed in by Martin Hepperle, 2019-2025
; -------------------------------------------------------
; utility functions
SOUND   EQU     $FF64   ; output sound.
                        ; A=Tone, B=Duration in 0.1 sec
GETCLK  EQU     $FF31   ; get clock.
                        ; X: address of 6 byte buffer (MM,DD,YY,HH,MM,SS in BCD)
SLEEP   EQU     $FFA9   ; set master MCU to sleep mode, returns when interrupt occurs.
                        ; test MIOSTS for which interrupt (e.g. TIM #CLOCKBIT,MIOSTS)
; -------------------------------------------------------
; 3-byte jmp vectors in table from $FED1 to $FFCF
HSTRIO   EQU    $FED1   ; jmp to HSTRIO I/O initialization, restart
WRTP26   EQU    $FED4   ; write to port 26
                        ; A=bitmask, B=data bits
; -------------------------------------------------------
; MSAVE/MLOAD
OPENLOD  EQU    $FEDA   ; open a file for memory load
BINLOAD  EQU    $FED7   ; load memory, close after loading
OPENDMP  EQU    $FEE0   ; open a file for memory dump
BINDUMP  EQU    $FEDD   ; memory dump, close after dump
; -------------------------------------------------------
MONITR   EQU    $FF10   ; jmp to start the monitor
REQINI   EQU    $FF13   ; jmp to cold start reset
;
RS232C   EQU    $FF16   ; jmp to input from RS-232C by slave CPU command
SNSCOM   EQU    $FF19   ; jmp to input send 1 command byte to slave CPU
SRINIT   EQU    $FF1C   ; jmp to initialize high speed serial interface
PWRDWN   EQU    $FF1F   ; jmp to battery voltage drop indicator "CHARGE BATTERY!"
KYSSTK   EQU    $FF22   ; place up to 18 characters in key stack at boot time
                        ; X: address of string
                        ; A: number of characters (0...18), 0 clears
MENU     EQU    $FF25   ; jmp to jump to MEND
BINDEC   EQU    $FF28   ; convert 16-bit BIN to ASCII decimal
                        ; A,B=BIN number 0...65536
                        ; X=address for 5-byte result
HEXBIN   EQU    $FF2B   ; convert 2-digit HEX to BIN
                        ; A,B=HEX digits, e.g. A='A',B='B' => A=0xAB
                        ; A=binary number, B=0:OK, B=1:ERROR, Z=B (for testing)
SETCLK   EQU    $FFF8   ; set clock.
                        ; X=address of 6 byte buffer (MM,DD,YY,HH,MM,SS in BCD)
; -------------------------------------------------------
; keyboard functions
INITKY   EQU    $FFA0   : initialize keyboard data structures
KEYSTS   EQU    $FF9D   ; return: A: # of keys in buffer
KEYIN    EQU    $FF9A   ; return: one byte codes: A: character code, 
                        ;         two byte codes: A=0xFE: B=character code
                        ; Function keys return FE in (A), key code in (B):
                        ; PF1:       A=FE,B=F1
                        ; SHIFT+PF1: A=FE,B=F6
                        ; PF5:       A=FE,B=F5
                        ; SHIFT+PF5: A=FE,B=FA
                        ; Note: BREAK, MENU, PAUSE and CTRL+PF1, CTRL+PF4, CTRL+PF5 are handled separately
KEYSCN   EQU    $FF6A   ; scans key matrix and updates NEWKTB
NEWKTB   EQU    $FFD0   ; address of NEWKTB table, typically $0145
COLCNT   EQU    $FFD2   ; address of columns in microprinter buffer
CSBFCM   EQU    $FFD4   ; address of bytes in external cassette buffer
MSBFCM   EQU    $FFD6   ; address of bytes in internal microcassette buffer
RDSCNT   EQU    $FFD8   ; address of bytes in RS-232C input buffer
LCSCRN   EQU    $FFDA   ; address of LCD physical screen
CASBUF   EQU    $FFDC   ; address of 260 byte cassette buffer
SCRLSP   EQU    $FFDE   ; address of scroll speed
CSHBUF   EQU    $FFE0   ; address of external cassette header buffer
MSHBUF   EQU    $FFE2   ; address of internal microcassette header buffer
KEYMOD   EQU    $FFE4   ; address of key input mode

; -------------------------------------------------------
; LCD functions
DSPLCN   EQU    $FF49   ; enter or clear a string on display and buffer
                        ; B: # of characters, 0: clear
                        ; X: address of data packet (x,y,c0,c1,...)
DSPLCH   EQU    $FF4C   ; enter character into buffer and display.
                        ; A: character
                        ; X: x,y
JMPDFFI  EQU    $FF4F   ; display one character of virtual screen
DISPIT   EQU    $FF5B   ; display character (not into buffer)
                        ; A: character.
                        ; X: x,y, updated on return to next position
JMPDFF4  EQU    $FF5E   ; call virtual screen function
CHRGEN   EQU    $FF67   ; generate a character pattern
                        ; A: character code
                        ; X: address of 6 byte buffer to receive definition
; -------------------------------------------------------
; High-Speed Serial functions
SERONF   EQU    $FF73   ; toggle Serial
                        ; A=0: OFF, A=1: ON
SERIN    EQU    $FF6D   ; Serial input
SEROUT   EQU    $FF70   ; Serial output
; -------------------------------------------------------
; RS-232C functions
RSGET    EQU    $FF79   ; RS-232C input
RSPUT    EQU    $FF76   ; RS-232C output
RSGSTS   EQU    $FF7C   ; RS-232C get status
RSCLOS   EQU    $FF7F   ; close RS-232C
RSOPEN   EQU    $FF82   ; open RS-232C
RSONOF   EQU    $FF85   ; toggle RS-232C power
                        ; A=0: OFF, A=1: ON
RSSTAT   EQU    $FF88   ; set RS-232C status register mode
RSMODE   EQU    $FF8A   ; set RS-232C mode register
; RS-232C variables
RSBAUD   EQU    $01AF   ; 2 bytes baud rate divisor
RSCRC    EQU    $01B1   ; 4 bytes CRC expression
RSBITL   EQU    $01B5   ; 1 byte bit length (8,7,6,5)
RSMODS   EQU    $01B6   ; 1 byte CD, RTS, DSR, CTS, Parity
RSSTSR   EQU    $01B7   ; 1 byte error status
RSBFAD   EQU    $01B8   ; 2 bytes starting address of receive buffer
RSBFBT   EQU    $01BA   ; 2 bytes last address of receive buffer plus 1
RSBFSZ   EQU    $01BC   ; size of receive buffer
RSINP    EQU    $01BC   ; 2 bytes address where next byte will be stored in receive buffer
RSOUP    EQU    $01C0   ; 2 bytes address where last byte will be fetched from receive buffer
RSDCNT   EQU    $01C2   ; 2 bytes number of data in receive buffer
; -------------------------------------------------------
; CS external cassette functions
OPNWCS   EQU    $FF3A   ; open file on external cassette for output
SRCRCS   EQU    $FF40   ; open external cassette file for input
CLOSCS   EQU    $FF34   ; close external cassette file
WRITCS   EQU    $FF37   ; write one byte to external cassette
READCS   EQU    $FF3D   ; read read byte from external cassette
PONFCS   EQU    $FF46   ; toggle the motor of the external cassette (remote on/off)
                        ; A=0: OFF, A=1: ON
; -------------------------------------------------------
; MC internal micro cassette functions
CNTRMC   EQU    $FEEF   ; read/write the micro cassette counter
SEEKMC   EQU    $FEF2   ; seek the micro cassette to the counter value given in (X)
REWNMC   EQU    $FEF5   ; rewind the micro cassette
CLOSMC   EQU    $FEFB   ; close file on the micro cassette
OPENMC   EQU    $FF01   ; open file on the micro cassette for output
OPNSMC   EQU    $FF0A   ; search and open file on the micro cassette for input
SRCOMC   EQU    $FF07   ; open first matching file on the micro cassette for input
READMC   EQU    $FF04   ; read one byte from file on the micro cassette
WRITMC   EQU    $FEFE   ; write one byte to file on the micro cassette
MANLMC   EQU    $FF0D   ; start micro cassette manual operation
; -------------------------------------------------------
; PROM cartridge functions
DIRPRM   EQU    $FEE3   ; read directory of PROM cartridge
OPENPRM  EQU    $FEEC   ; open a file on the PROM cartridge
CLOSPRM  EQU    $FEE6   ; close a file on the PROM cartridge
READPRM  EQU    $FEE9   ; read one character on the PROM cartridge
; -------------------------------------------------------
; built-in printer functions
PRTDOT   EQU    $FF91   ; print 144 dot line.
                        ; X: address of a 24 byte buffer (5 bits used)
NDFEED   EQU    $FF8F   ; perform n dot lines of line feed
SCRCPY   EQU    $FF8B   ; screen copy
LNPRNT   EQU    $FF94   ; print one line of characters.
                        ; X: address of 24 byte buffer
CHPRNT   EQU    $FF97   ; print one character.
                        ; A: character code. LF:prints, CR advances
; variables
CHRPTN   EQU    $0190   ; work area for character font
COLCNT   EQU    $0196   ; data count in buffer [0...24] 
CHRDAT   EQU    $0197   ; buffer data for 1 line of characters
; -------------------------------------------------------
; various functions
CHKPLG   EQU    $FF2E   ; check connected plug-in options
PWROFF   EQU    $FFAC   ; power off
; -------------------------------------------------------
; main CPU memory map:
; i/o ports
P1DIR    EQU    $0000   ; RS-232C
P1ADDR   EQU    $0002   ; address
P2DIR    EQU    $0001   ; RS-232C
P2ADDR   EQU    $0003   ; address
P3DIR    EQU    $0004   ; A0..A7,D0..D7
P3ADDR   EQU    $0006   ; address
P4DIR    EQU    $0005   ; A8..A15
P4ADDR   EQU    $0007   ; address
; -------------------------------------------------------
TIMCTL   EQU    $0008   ; timer control
COUNTER  EQU    $0009   ; free running 16-bit counter
OUTCMP   EQU    $000B   ; 16-bit output compare register
INPCAP   EQU    $000D   ; 16-bit input capture register
P3CNTL   EQU    $000F   ; P3 control register
; -------------------------------------------------------
SERSPD   EQU    $0010   ; serial speed rate
SERCTL   EQU    $0011   ; serial control status
SERRCV   EQU    $0012   ; serial receive data register
SERSND   EQU    $0013   ; serial transmit data register
; -------------------------------------------------------
RAMCTL   EQU    $0014   ; external/internal RAM switching
; -------------------------------------------------------
;      $0015 .. $001F   ; unused
; -------------------------------------------------------
KBDSCN   EQU    $0020   ; output keyboard scan KSC 0 to 7 output, SW6 read
KBDRT1   EQU    $0022   ; input keyboard scan KRTN 0 to 7
KBDRT2   EQU    $0028   ; input keyboard scan KRTN 8 and 9
; -------------------------------------------------------
; RTC I/O registers
RTCSEC   EQU    $0040   ; seconds
RTCSCA   EQU    $0041   ; seconds alarm
RTCMIN   EQU    $0042   ; minutes
RTCMNA   EQU    $0043   ; minutes alarm
RTCHRS   EQU    $0044   ; hours
RTCHRA   EQU    $0045   ; hours alarm
RTCDAY   EQU    $0046   ; day
RTCDATE  EQU    $0047   ; date (what is this ?)
RTCMON   EQU    $0048   ; month
RTCYEAR  EQU    $0049   ; year
RTCREGA  EQU    $004A   ; RTC control register A
RTCREGB  EQU    $004B   ; RTC control register B
RTCREGC  EQU    $004C   ; RTC control register C
RTCREGD  EQU    $004D   ; RTC control register D
; -------------------------------------------------------
LOWRAM   EQU    $004E   ; 4E...7F   50 bytes RAM, (see p.14-7)
                        ; used by e.g. I/O routines, switches
PWRFLG   EQU    $004E   ; 1 byte clock power on mode (see p.14-7)
P26      EQU    $004F   ; address 26 port data (see p.14-7)
R0       EQU    $0050   ; 16-bit I/O work area (see p.14-7)
; ...
R7       EQU    $005E   ; 16-bit I/O work area (see p.14-7)
M0       EQU    $0060   ; 16-bit monitor work area (see p.14-7)
; ...
M7       EQU    $006E   ; 16-bit monitor work area (see p.14-8)
K0       EQU    $0070   ; 16-bit keyboard work area (see p.14-8)
K1       EQU    $0072   ; 16-bit keyboard work area (see p.14-8)
S0       EQU    $0074   ; 16-bit keyboard work area (see p.14-8)
S1       EQU    $0076   ; 16-bit keyboard work area (see p.14-8)
INIFL1   EQU    $0078   ; 1 byte cold start flag (see p.14-8)
PLGSTS   EQU    $0079   ; 1 byte plug in options (see p.14-8)
SRSTS    EQU    $0079   ; 1 byte RS-232C status (see p.14-9)
RUNMOD   EQU    $007B   ; 1 byte program execution mode (see p.14-9)
SIOSTS   EQU    $007C   ; 1 byte slave I/O status bits  (see p.14-10)
MIOSTS   EQU    $007D   ; 1 byte main I/O status, interrupt flag bits  (see p.14-10)
SDIPS1   EQU    $007E   ; 1 byte software switch bits  (see p.14-10)
SDIPS2   EQU    $007F   ; 1 byte DIP switch bits (see p.14-11)
; -------------------------------------------------------
; BASIC work area
BASRAM   EQU    $0080   ; 80...FF   128 bytes BASIC RAM
FPTYP    EQU    $0085   ; 2-bytes
                        ; type of number in FPACC
FPACC    EQU    $00D5   ; 8 bytes
                        ; BASIC floating point accumulator
CURADR   EQU    $009C   ; address of current area
VARTOP	EQU    $009E	; address of start of scalar variables
ARRTOP	EQU    $00A0	; address of start of array variables
ARREND	EQU    $00A2	; address of end of array variables
STRTOP	EQU    $00A6	; address of start of string space
STREND	EQU    $00AA	; address of end of string space

; -------------------------------------------------------
INTCLK   EQU    $0100   ; 3 bytes JMP + address of real time interrupt routine
INTEXT   EQU    $0103   ; 3 bytes JMP + address of external IRQ1 interrupt routine
INTRAP   EQU    $0106   ; 3 bytes JMP + address of TRAP interrupt routine
INTSCI   EQU    $0109   ; 3 bytes JMP + address of IRQ1 SCI interrupt routine
INTTOF   EQU    $010C   ; 3 bytes JMP + address of IRQ1 TOF interrupt routine
INTOCF   EQU    $010F   ; 3 bytes JMP + address of IRQ1 OCF interrupt routine
INTICF   EQU    $0112   ; 3 bytes JMP + address of IRQ1 ICF interrupt routine
INTIRQ   EQU    $0115   ; 3 bytes JMP + address of IRQ1 interrupt routine
INTSW1   EQU    $0118   ; 3 bytes JMP + address of SW1 routine
INTNMI   EQU    $011B   ; 3 bytes JMP + address of NMI routine
FONTS    EQU    $011E   ; 2 bytes address of character bitmaps for codes E0 to FF
; some key press vectors
BRKADR   EQU    $0120   ; 2 bytes address of BREAK key routine when out of BASIC
MENADR   EQU    $0122   ; 2 bytes address of MENU key routine when out of BASIC
PAUADR   EQU    $0124   ; 2 bytes address of PAUSE key routine when out of BASIC
CT3ADR   EQU    $0126   ; 2 bytes address of CTRL/PF3 key routine
CT4ADR   EQU    $0128   ; 2 bytes address of CTRL/PF4 key routine
CT5ADR   EQU    $012A   ; 2 bytes address of CTRL/PF5 key routine
RMBEND   EQU    $012C   ; 2 bytes address of end of RAM + 1
RMLTAD   EQU    $012C   ; 2 bytes address of end of RAM + 1
PRMCNT   EQU    $012E   ; 2 bytes address where amount of data remaining in PROM cartridge is stored
WAKADR   EQU    $0130   ; 2 bytes address of clock alarm interrupt routine
POFADR   EQU    $0132   ; 2 bytes address of routine called before Power Off
; -------------------------------------------------------
BASTAB   EQU    $0134   ; 2 bytes address of start of BASIC application area
BSWTAD   EQU    $0134   ; 2 bytes start address of BASIC application area
CNDADR   EQU    $0136   ; 2 bytes address of start of BASIC program area
BSWBAD   EQU    $0136   ; 2 bytes address of BASIC program area
BSWPAK   EQU    $0138   ; 2 bytes address of BASIC save and condense routine
BITMP0   EQU    $013A   ; 1 byte bitmap for bank 0
BITMP1   EQU    $013B   ; 1 byte bitmap for bank 1
LNKTBL   EQU    $013C   ; 2 bytes address of RAM application link table
; -------------------------------------------------------
; keyboard variables
KSTKSZ   EQU    $0140   ; size of key stack (default: 8)
KICNT1   EQU    $0141   ; time until key repeat starts (default: 40*20ms)
KICNT2   EQU    $0142   ; time until next key repeat (default: 6*20ms)
KICNTM   EQU    $0143   ; sampling time (default: 12288=20ms)
NEWKTB   EQU    $0145   ; NEWKTB table, 10 bytes
OLDKTB   EQU    $014F   ; OLDKTB table, 10 bytes
CHKKTB   EQU    $0159   ; new keypress table, 10 bytes
KYISAD   EQU    $0163   ; address of key repeat (default: 016F)
KYISFL   EQU    $0165   ; power-on key auto stack data flag
KYISCN   EQU    $0166   ; number of keys in auto stack
KYISPN   EQU    $0167   ; index of current key (0...KYISCN)
STKCNT   EQU    $0168   ; number of keys in stack (0...KSTKSZ)
KEYMOD   EQU    $0169   ; input key mode (upper case, numeric, ...)
ONKFLG   EQU    $016A   ; key input enable/disable
KPRFLG   EQU    $016B   ; auto-repeat count
KEYRPT   EQU    $016C   ; matrix pos. of auto.repeat key
CKEYRD   EQU    $016D   ; input key code(s) (1-2)
KYISTK   EQU    $016F   ; work area for power on key stack (18 bytes)
CHRSTK   EQU    $0181   ; work area for key stack (8+7 bytes)
; -------------------------------------------------------
; RS-232C work area
RSFIRST  EQU    $01AF    ; 21 bytes RS-232C work area
RSLAST   EQU    $01C3    ; last byte of RS-232C work area
; -------------------------------------------------------
; serial work area
SERFIRST EQU    $01C4    ; 18 bytes serial work area
SERLAST  EQU    $01D5    ; last byte of serial work area
; -------------------------------------------------------
; external cassette work area
CASFIRST EQU    $01D6    ; 22 bytes cassette work area
CASLAST  EQU    $01EB    ; last byte of cassette work area
; -------------------------------------------------------
; internal micro cassette work area
MCFIRST  EQU    $01EC    ; 28 bytes micro cassette work area
MCLAST   EQU    $0207    ; last byte of micro cassette work area
; -------------------------------------------------------
; PROM cartridge variables (7 bytes)
PRMSTS   EQU    $0208    ; 1 bytes ROM cartridge status
STAPRS   EQU    $0209    ; 2 bytes address counter
FTSDRS   EQU    $020B    ; 2 bytes address of start of file
EDADRS   EQU    $020D    ; 2 bytes address of last end of file + 1
; -------------------------------------------------------
; binary memory dump/load work area
; used by OPNDMP, BIDUMP and OPNLOD, BILOAD routines
MLDFIRST EQU    $020F    ; 12 bytes load/dump work area
DLTPAD   EQU    $020F    ; 16-bit first dump address
DLBPAD   EQU    $0211    ; 16-bit last dump address
DLOFAD   EQU    $0213    ; 16-bit offset value
DLSTAD   EQU    $0215    ; 16-bit program entry point
DLDVID   EQU    $0217    ; 1 byte dump/load device
DLSTS    EQU    $0218    ; 1 byte status work area (dummy)
DLDVIX   EQU    $0219    ; 16-bit table address of dump routine
MLDLAST  EQU    $021A    ; last byte of load/dump work area
; -------------------------------------------------------
; reserved work area
RSVFIRST EQU    $021B    ; 5 bytes reserved work area
RSVLAST  EQU    $021F    ; last byte of reserved work area
; -------------------------------------------------------
; LCD screen variables ($0220-$029F)
PSBUF    EQU    $0220    ; buffer for physical screen (20x4 bytes)
SCRTOP   EQU    $0270    ; start address of virtual screen buffer
SCRBOT   EQU    $0272    ; end address of virtual screen buffer
DISTOP   EQU    $0274    ; address of (0,0) of physical on virtual screen
VSCRX    EQU    $0276    ; virtual screen width (max. x-coordinate)
VSCRY    EQU    $0277    ; virtual screen height (max. y-coordinate)
CURX     EQU    $0278    ; cursor x-coordinate on physical screen
CURY     EQU    $0279    ; cursor x-coordinate on physical screen
LRMODE   EQU    $027A    ; scroll step x
UDMODE   EQU    $027B    ; scroll step y
CURMRG   EQU    $027C    ; cursor margin (1...10)
SSPEED   EQU    $027D    ; scroll speed (0...9)
DISPX    EQU    $027E    ; x-coordinate of of character to be displayed (0...19)
DISPY    EQU    $027F    ; y-coordinate of of character to be displayed (0...3)
DISSTS   EQU    $0280    ; display status
CHRPTL   EQU    $0286    ; character result from CHRGEN (6 bytes)
; -------------------------------------------------------
; monitor work area, 48 bytes
MONBP1   EQU    $02A0    ; 2 bytes breakpoint address
MONBPD1  EQU    $02A2    ; 1 byte value at breakpoint address
MONLCDST EQU    $02A3    ; 1 byte LCD status
MONBUF   EQU    $02A4    ; 27 bytes binary dump/load work area
MONPC    EQU    $02BF    ; 2 bytes program counter
MONRTN   EQU    $02C1    ; 2 bytes return address for B command
MONLAST  EQU    $02C3    ; 2 bytes address of last char on first line
MONSMOD  EQU    $02C5    ; 1 byte R option of R command
MONRTN   EQU    $02C6    ; 10 bytes unused, can be used for temp buffer 
MONLAST  EQU    $02CF    ; last byte of monitor unused area
; -------------------------------------------------------
; external cassette header work area
CASFIRST EQU    $02D0    ; 84 bytes external cassette header work area
CASLAST  EQU    $0323    ; last byte of external cassette header work area
; -------------------------------------------------------
; internal micro cassette header work area
CASFIRST EQU    $0324    ; 84 bytes internal cassette header work area
CASLAST  EQU    $0377    ; last byte of internal cassette header work area
; -------------------------------------------------------
; system buffer area ($0378-$047C = 261 bytes)
BUFFIRST EQU    $0380    ; 253 bytes system buffer area
BUFLAST  EQU    $047C    ; last byte of system buffer area
;                        ; (manual says : 260 bytes buffer, starting at $0380) 
; -------------------------------------------------------
MEMSET   EQU    $0500   ; 2 bytes. MEMSET value, start address of BASIC program
CMD0     EQU    $05A6   ; address of BASIC command table 0
FNC0     EQU    $05AB   ; address of BASIC function table 0
; -------------------------------------------------------
; device drivers
DCBTAB   EQU    $0657   ; start of DCB table.
                        ; stores up to sixteen 16-bit addresses of DCBs
          ; Contents of DCB table after initialization of this area by BASIC
          ; defines these 7 devices: 
          ;       ADDR NAME IO OPEN CLOS READ WRIT EOF  LOF
          ; 0657: 069C KYBD 10 B3E4 B3E4 A969 B730 B3E4 B3E4 ...
          ;       06B6 SCRN 20 B3E4 B3E4 B3E4 B730 B3E4 B3E4 ...
          ;       06D0 COM0 30 B06A B0B3 B043 B111 B013 B00D ...
          ;       06EA CAS0 30 AD8D ADDA AE32 AE70 AE7C B3E4 ...
          ;       0704 CAS1 30 AD8D ADDA AE32 AE70 AE7C B3E4 ...
          ;       071E PAC0 10 B195 B200 B209 B128 B01F B01B ...
          ;       0738 LPT0 20 B3E4 B024 B3E4 B02F B3E4 B3E4 ...
          ;       0000 .. end of list
; Device Control Block Example
; DCB:    FCB     "STAT"          ; 4 character name
;         FCB     $30             ; I/O mode: $01: r, $20: w, $30: r/w
;         FDB     OPENDEV         ; OPEN routine
;         FDB     CLOSEDEV        ; CLOSE routine
;         FDB     READDEV         ; READ routine
;         FDB     WRITEDEV        ; WRITE routine
;         FDB     EOFDEV          ; EOF routine
;         FDB     LOFDEV          ; LOF routine
; DEVBUF: FCB     $00,$00,$00,$00 ; used for device purposes
; COLPOS: FCB     $00             ; current column position, see POS(#)
; MAXCOL: FCB     $00             ; max. column: $00: infinite
; PRTTAB: FCB     $14             ; print zone width of "," separated PRINT output
; LSTTAB: FCB     $00             ; last print zone on line
; WIDTH:  FCB     $80             ; WIDTH support: $00: yes, $80: no
; -------------------------------------------------------
