10 REM --- Epson HX-20      ---
20 REM --- M. Hepperle 2024 ---
21 REM Installs a device "STAT".
22 REM Writing to it counts the 
23 REM number of occurrances of
24 REM each character code (0...255).
25 REM Reading returns 256*2 bytes
26 REM (high,low) which represent the
27 REM accumulated number of each character.
28 REM One can use LIST "STAT:" to count
29 REM how often each character occurs.
30 REM --- adjust BASIC starting address
40 MEMSET &HCB3
50 REM --- load the code bytes
60 GOSUB 1000
70 REM --- install the driver
80 GOSUB 1200
90 REM --- application example: write something to STAT:
100 OPEN "O",#1,"STAT:"
110 FOR I%=1 TO 300
120  PRINT#1,CHR$(0)+"AAAABBBCCD"+CHR$(255)
130 NEXT I%
140 CLOSE #1
145 REM --- read counts from STAT: e.g. after LIST "STAT:"
150 PRINT "Finding maximum count..."
160 MX=0
170 OPEN "I",#1,"STAT:"
180 FOR I%=0 TO 255
190  H$=INPUT$(1,#1) : L$=INPUT$(1,#1)
200  Y=ASC(H$)*256+ASC(L$)
210  IF Y>MX THEN MX=Y
220 NEXT I%
230 CLOSE #1
240 GCLS
245 REM --- read counts and normalize with MX
250 OPEN "I",#1,"STAT:"
260 FOR I%=0 TO 127
270  H$=INPUT$(1,#1) : L$=INPUT$(1,#1)
280  Y%=31*(1-(ASC(H$)*256+ASC(L$))/MX)
290  LINE(I%,31)-(I%,Y%),PSET
300 NEXT I%
310 CLOSE #1
320 SOUND 33,2
330 C$=INPUT$(1) : REM wait for [Enter] key
340 END
1000 REM --- Hex Code Loader ---
1010 N%=0
1020 READ C$
1030 IF C$="DONE" THEN 1080
1040 N%=N%+1 : IF N%=8 THEN PRINT "."; : N%=0
1050 C%=VAL("&H"+C$)
1060 IF LEN(C$)=4 THEN A%=C% : GOTO 1020
1070 POKE A%,C% : A%=A%+1 : GOTO 1020
1080 PRINT
1090 RETURN
1200 REM --- Device Installer ---
1210 DCBTAB%=&H0657
1220 FOR A%=DCBTAB% TO DCBTAB%+30 STEP 2
1230 C%=PEEK(A%)*256+PEEK(A%+1)
1240 IF C%=&H0A40 THEN GOTO 1300
1250 IF C%=&H0000 THEN GOTO 1270
1260 NEXT A%
1270 IF A%>DCBTAB%+28 THEN GOTO 1320
1280 POKE A%,&H0A : REM HIGH
1290 POKE A%+1,&H40 : REM LOW
1300 PRINT "STAT: at &H";HEX$(A%)
1310 RETURN
1320 PRINT "DCB table full!"
1330 STOP
2141 DATA 0A40,53,54,41,54,30,0A,5A,0A,78,0A,79,0A,8F,0A,9F,0A,AB,00
2142 DATA 00,00,00,00,00,14,00,80,B6,06,8A,81,10,27,10,CE,0A,B1,86,FF
2143 DATA 6F,00,6F,01,08,08,4A,81,FF,26,F5,CE,0A,B1,FF,0C,B1,39,39,7F
2144 DATA 00,F5,FE,0C,B1,8C,0C,B1,27,07,A6,00,08,FF,0C,B1,39,7A,00,F5
2145 DATA 39,36,33,4F,05,C3,0A,B1,18,EC,00,F3,0A,AF,ED,00,39,5F,FE,0C
2146 DATA B1,8C,0C,B1,27,01,39,5A,39,CC,00,02,39,00,01,DONE

