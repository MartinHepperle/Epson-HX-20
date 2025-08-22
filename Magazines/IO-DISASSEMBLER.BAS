
Translation of the Japanese text

The HC-20 has a decent monitor and which can be used for writing machine language programs.
However, the firmware in the ROM is still not publicly available.
So you have to write your own input/output routines or analyze the ROM.
Also, the HC-20's MCU is a 6301 (MCU: Microcomputer Unit), which is supposedly 6800 compatible but has some additional instructions, serial and parallel interfaces, and even a timer, so you can't write input/output routines without analyzing the ROM.
So, first I made a disassembler. Of course, the program was written in BASIC.

How to Use
LOAD the program or type it in exactly as listed. Then RUN it. 
It will display "6301V Dis-assembler" and then ask you to select the output device:
"Output to 
1. LCD
2. Printer
3. COM0: 
Select 1-3"
If you want to display on the LCD display, press 1; if you want to use the built-in printer, press 2; if you want to output to a printer connected to the RS-232C port, press 3.
It will ask for the first address to disassemble: "Start address:?"; enter it in hexadecimal and diassembly will begin.
To stop disassembly, press the SPACE bar.
Press the SPACE bar again to resume disasembly.
If you want to start from a different address, stop disassebly with the SPACE bar, then enter the new start address in hexadecimal.
To stop progam execution, press the RETURN key, You can either press it while disassembling or immediately after pausing the display with the SPACE bar. ">End of Dis-assemble".
So everyone, let's do our best to analyze the ROM.

Table 1: Instruction execution cycles for the 6800, 6809 and 6301
Instruction	6800	6809	6301
BEQ	4	3	3
BSR	8	7	6
JSR (Ext)	9	8	6
JSR (Ind)	8	8	5
LDAA (Imm)	2	2	2
LDAA (Dir)	3	4	3
LDAA (Ind)	5	5	4
LDAA (Ext)	4	5	4
ROLA	2	2	1
ROL (Ind)	7	7	6
ROL (Ext)	6	7	6
TSTA	2	2	1
TST (Ind)	7	7	4
TST (Ext)	6	7	4
LDX (Imm)	3	3	3
LDX (Dir)	4	5	4
LDX (Ind)	6	6	5
LDX (Ext)	5	6	5
PSHA	4	5	4
MUL	-	11	6


0 '*****************
1 '* HC-20 - 6301V *
2 '* Dis-Assembler *
3 '*    ver.1.1    *
4 '*   1982.8.27.  *
5 '* by ????????   *
6 ' ****************
10 GOTO1000:'---> Initialize
19 '
20 '===== Addressing Mode =====
30 D=PEEK(A):A=A+1:B$=B$+FNR$:O$=O$+" #$"+FNR$:RETURN:'<---Immediate---
35 D=PEEK(A):C$=FNR$:O$=O$+" #$"+FNR$
37 D=PEEK(A+1)*A=A+2:C$=C$+FNR$:O$=O$+FNR$:RETURN:'<---16bit-Immedaite---
40 D=PEEK(A):A=A+1:B$=B$+FNR$:O$=O$+" $"+FNR$:RETURN:'<---Direct---
50 D=PEEK(A):A=A+1:B$=B$+FNR$:O$=O$+" $"+FNR$+",X":RETURN:'<---Indexed---
60 D=PEEK(A):C$=FNR$:O$=O$+" $"+FNR$:D=PEEK(A+1):A=A+2
65 C$=C$+FNR$:O$=O$+FNR$:RETURN:'<---Extended---
70 O$="A":RETURN:'<---Acc.A---
75 O$="B":RETURN:'<---Acc.B---
80 IF D<32 THEN M$=FCB":O$=" $"+FNR$ ELSE M$="FCC":C$=" /"+CHR$(D)+"/"
85 RETURN:'<---Undefined OP code---
99
100 '===== Main-routine =====
110 A$=FNA$(STR$(A))+" ":O$="":C$=""
120 D=PEEK(A):A=A+1:B$=FNR$:U=d\16:L=D MOD 16
130 IF U<4 THEN GOSUB 500 ELSE M=(U MOD 4)+1:IF U<8 THEN GOSUB 400 ELSE GOSUB 300
149 '
150 '===== Print routine =====
160 ON P GOSUB 180,200:Y$=INKEY$:IF Y$=CHR$(13) THEN 280 ELSE IF Y$<>" " THEN 110
162 IF P>1 THEN PRINT "Start address:";
Y$=INKEY$:IFY$="" THEN 164 ELSE IF Y$=" " THEN 110 ELSE IF Y$=CHR$(13) THEN 280
165 IF P=1 THEN PRINT:PRINT"Start address: ";Y$;ELSE PRINT Y$;
166 A$=INKEY$:IF A$="" THEN 166 ELSE IF A$<>CHR$(13) THEN Y$=Y$+A$:PRINT A$;:GOTO 166
168 V=VAL("&H"+Y$):IF V>-1 AND V<&H4F THEN 162 ELSE A=V:IF P=3 THEN GOSUB 240
169 GOTO 100
170 '--- to LCD ---
180 PRINT:PRINT A$;B$;C$;TAB(5);M$;" ";O$;:RETURN
190 '--- to PRINTER ---
200 LPRINT A$;B$;TAB(10);M$;" ";O$;:IF C$<>"" THEN LPRINT TAB(5);C$
210 RETURN
220 '--- to COM0: ---
230 PRINT#3,A$;B$;C$;TAB(20);M$;" ";O$:G=G+1:IF G<60 THEN RETURN
240 PRINT#3,CL$;"*6301V DIS-ASSEMBLE LIST              by T.OMURA     ";DATE$
250 PRINT#3,CHR$(10):G=0:RETURN
269 '
270 '===== E N D =====
280 PRINT:PRINT">END of Dis-assemble":END
289 '
290 '===== Mnemonics =====
300 '--- 2 bytes ---
310 M$=N$(L,5)
315 ON L GOTO 320,320,340,320,320,320,350,320,320,320,320,360,370,380,390
320 IF U<12 THEN O$="A " ELSE O$="B "
330 ON M GOTO 30,40,50,60
335 ON M GOTO 35,40,50,60
340 IF U>11 THEN M$="ADDD":GOTO 335 ELSE 335
350 IF M=1 THEN 80 ELSE 320
360 IF U>11 THEN M$="LDD":GOTO 335 ELSE 335
370 IF U>11 THEN M$="STD":IF M=1 THEN 80 ELSE 330
375 IF M=1 THEN M$="BSR":GOTO 520 ELSE 330
330 IF U>11 THEN M$="LDX":GOTO 335 ELSE 335
390 IF U>11 THEN M$="STX"
395 IF M=1 THEN 80 ELSE 330
400 '--- 1 byte ---
410 M$=N$(L,4):ON L GOTO 430,430,420,420,430,420,420,420,420,420,430,420,420,480
420 IN M GOTO 70,75,50,60
430 IF M<3 THEN 80 ELSE D=PEEK(A):A=A+1:C$=FNR$:O$="#$"+FNR$:'<---OIM,EIM,etc---
440 D)PEEK(A):A=A+1:C$=C$+FNR$:O$=O$+" $"+FNR$:IF M=3 THEN O$=O$+",X"
450 RETURN
470 '--- JMP ---
490 ON M GOTO 80,80,50,60
500 '--- ---
510 M$=N$(L,U):IF M$="" THEN 80 ELSE IF U<>2 THEN RETURN:'<---Implied---
520 D=PEEK(A):A=A+1:B$=B$+FNR$:O$=" $"+FNA$(STR$(A+D)):RETURN:'<---Branch---
999 '
1000 '===== Initialize =====
1010 WIDTH 20,20:DIM N$(15,5):CL$=CHR$(12):PRINT" 6301V Dis-Assembler "
1020 DEF FNR$=RIGHT$("0"+HEX$(D),2):DEF FNA$(D$)=RIGHT$("000"+HEX$(VAL(D$)),4)
1030 FOR J=0 TO 5:FOR I=0 TO 15:READ N$(I,J):NEXT:NEXT
1050 PRINT"Output to 1,LCD";TAB(10);"2.Printer";TAB(10);"3.COM0:","Select 1-3";
1060 M$=INKEY$:IG M$="" THEN 1060 ELSE P=VAL(M$):IF P<1 OR P>3 THEN PRINT:GOTO 1050
1070 IF P=3 THEN OPEN"O",3,"COM0:":GOSUB 240
1100 PRINT:INPUT"Start address:";A$:A=VAL("&H"+A$):IF A>&H48 OR A<0 THEN 100
1110 FOR J=1 TO 3:SOUND 16,1:SOUND 0,1:NEXT:GOTO 1100
2999 '
3000 '===== =====
3010 DATA ,NOP,,,LSRD,ASLD,TAP,TPA,INX,DEX,CLV,SEV,CLC,SEC,CLI,SEI
3020 DATA SBA,CBA,,,,,TAB,TBA,XGDX,DAA,SLP,ABA,,,,
3030 DATA BRA,BRN,BHI,BLS,BCC,BCS,BNE,BEQ,BVC,BVS,BPL,BMI,BGE,BLT,BGT,BLE
3040 DATA TSX,INS,PULA,PULB,DES,TXS,PSHA,PSHB,PULX,RTS,ABX,RTI,PSHX,MUL,WAI,SWI
3050 DATA NEG;AIM,OIM,COM,LSR,EIM,ROR,ASR,ASL,ROL,DEC,TIM,INC,TST,JMP,CLR
3060 DATA SUB,CMP,SBC,SUBD,AND,BIT,LDA,STA,EOR,ADC,ORA,ADD,CPX,JSR,LDD,STS
