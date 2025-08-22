Apocalypse of Hell
AHOMAIL
Half a year has passed since the release of the HC-20 handheld computer, but there ar ehardly any sotware (especially games) released. As an HC user, I find it very uninteresting. I understand that it is difficult to make games with a 20 x 4 LCD and CMOS.
However, asl I continued to work on it, I began to understand how to make games in HC, so I would like to announce it here.

Virtal Screen
The biggest bottleneck when making a game on the HC is the virtual screen.
Bacause the display is an LCD, there is no VRAM like in normal machines, and the routines in the ROM have not yet been clarified, so you have to write to the virtual screen and then transfer it with BASIC. The top address of the virtual screen was in the December isuue, but there is no need to distinguish between cases like that; it's just written to the two bytes startinf from $0270.

Key Buffer
There is INKEY$ for real-time key input, bit this is also a bit troublesome.
The buffer stores up to 8 bytes when an interrupt occurs, so if you create a game using this, it will behave strangely. So if you write the I/O port bit pattern to $20 and read $22, you can achieve the same thing as INP on the PC-8001. However, in this case, BREAK will not work, so when you're done, write $00 to $20. In other words, if the bit is 0, the circuit is open, and if it is 1, it is closed (obviously). For details, please rfer to the circuit diagram.

Apocalypse of Hell
Now, let's finally explain the game. The reason why I chose this game is its speed and difficulty. The machine language routines are full of bug fix routines, but the HC.

I just want to let you know that I can do this much, so please enter it.
As for the rules, I (arbitraily) thoight that 1 point per base was too low for a game this difficult, so in the HC version I set it at 10 points per base and 1 point for each step taken, and used 2 bytes for scoring.
The keys are [I] up, [J] down and [A] to drop bombs, allowing you to fire continuously. The top of the HC keyboard is a little loose, so you want to avoid hitting the eys as much as possible. Annother difference from the PC version is that there are only four characters vertically, so the tarrain was not changed. However, the enemy bullets are fast, so I think it is difficult enough. If you still think this is easy, try changing the comparison value on line 210.
Make sure the scroll speed is set to 9. Otherwise it will be slow and frustrating.

When entering a program, first type MEMSET &HCB5 into the keyboard and the execute it. If you forget, you will be in trouble.
The machine code is in $0A50-$0C5A. How to use the monitor is described on page 40 of the operation manual.

At the End
This time, I didn't use any routines in ROM. In other words, I'm runningat the BASIC level. Someone please decipher the ROM (especially the print routine).

To all HC users across the country, the HC-20 is the best. Let's all release our software together and make the HC a more popular machine!

References
1) Atsushi Uno, "Apocalypse Now", I/P, December 1980 issue.
2) HC-20 Operation Manual, Epson.


10 '**************  
20 '* APOCALYSE  *
30 '*        NOW *  I/O Magazine 03/1983
40 '*    by S.T  *  I rise
50 '*  82/11/14  *  J fall
60 '**************  A drop bombs
70 MEMSET &H0C5D
70 REM LOADM "CAS0:VRAM.BIN",&H0A50
80 GOSUB 2000
100 WIDTH20,4:DEFINTA-Z:RANDOMIZEVAL(RIGHT$(TIME$(,2))
110 POKE&H7E,&H80:POKE&H11E,11:POKE&H11F,&HCA:V=PEEK(&H270)*256+PEEK(&H271)+8
120 PRINT CHR$(23);:X=224:FORI=1TO12:FORJ=1TO2:LOCATEI,J:PRINTCHR$(X);:X=X+1:NEXTJ,I:GOSUB310
130 FORI=0TO38:LINE(I+3,0)-(I+3,31),PSET:LINE(80-I,0)-(80-I,31),PSET:NEXT
140 FORI=0TO15:LINE(6,15-I)-(77,15-I),PRESET:LINE(6,616+I)-(77-16+I),PRESET:NEXT
150 FORI=0TO2:LOCATE1,I:PRINTSPC(12);:NEXT:LOCATE1,3:PRINTSTRING$(12,"#");
160 LOCATE14,0:PRINT"SCORE";:LOCATE14,1:PRINT"    0";:LOCATE14,2:PRINT"High";:LOCATE14,3:PRINTUSING"#####";HS;
170 POKE&H11F,&H68:POKE&HA40,0:POKE&HA41,0:POKE&HA4E,0:POKE&HA4F,0
180 LOCATE8,0:PRINTCHR$(233)+CHR$(234);
190 EXEC&HA50:IFRND(1)<.2THENLOCATE1,3:PRINTCHR$(228);ELSELOCATE1,3:PRINTCHR$(INT(RND(1)*4+224));
200 LOCATE1,4:PRINTUSING"#####";PEEK(&HA4E)*256+PEEK(&HA4F);
210 IFRND(1)<.4THENLOCATERND(1)*10+2,2:PRINTCHR$(229);
220 IFPEEK(V+PEEK(&HA41)*20)=229THEN POKE&HA40,3:GOTO240ELSEONPEEK(&HA40)+1GOTO190,230,230,240,240
230 SOUND10,2:GOTO190
240 LOCATE8,PEEK(&HA41):PRINT"**";:FORI=1TO5:SOUND4,1:SOUND2,1:NEXT
250 LOCATE1,0:IFPEEK(&HA40)=3THENPRINT" Kiwai Leta!";ELSEPRINT"Shi Mennike Kitotsu!";
260 LOCATE2,1:PRINT"*GAMEOVER*":SOUND16,8
270 S=PEEK(&HA4E)*256+PEEK(&HA4F):IFS>HSTHENHS=S
280 LOCATE14,3:PRINTUSING"#####";HS;
290 LOCATE2,3:PRINT"Replay  <Y>";:POKE&H20,0
300 A$=INKEY$:IFA$="Y"THEN130ELSEIFA$<>"N"THEN300ELSECLS:END
310 RESTORE:FORI=1TO19:READA,B:SOUNDA,B:NEXT:RETURN
320 DATA5,3,2,1,5,1,7,5,5,5,7,3,5,1,7,1,9,5,7,5,9,3,7,1,9,1,39,5,32,5,7,3,32,1,7,1,9,7
2000 REM --- Epson HX-20      ---
2001 REM --- M. Hepperle 2024 ---
2002 REM --- adjust BASIC starting address
2003 REM --- load the code bytes
2004 REM --- Hex Code Loader ---
2005 MEMSET &H0C5D
2006 N%=0
2007 READ C$
2008 IF C$="DONE" THEN 2013
2009 N%=N%+1 : IF N%=10 THEN PRINT "."; : N%=0
2010 C%=VAL("&H"+C$)
2011 IF LEN(C$)=4 THEN A%=C% : N%=0 : GOTO 2007
2012 POKE A%,C% : A%=A%+1 : GOTO 2007
2013 PRINT
2014 REM SAVEM "CAS0:VRAM.BIN",&H0A50,&H0C5C
2015 END
2016 DATA 0A50,7F,0A,40,86,0B
2017 DATA F6,0A,41,BD,0B
2018 DATA 50,C6,20,E7,00
2019 DATA C6,2E,E7,01,7D
2020 DATA 0A,43,27,0A,F6
2021 DATA 0A,42,BD,0B,30
2022 DATA 86,E7,A7,00,86
2023 DATA 0B,5F,BD,0B,50
2024 DATA E6,00,C1,E5,26
2025 DATA 02,C6,20,E7,01
2026 DATA 4A,26,EF,C6,01
2027 DATA 86,0B,BD,0B,50
2028 DATA 37,E6,00,C1,E5
2029 DATA 26,04,BD,0B,B4
2030 DATA 01,E7,01,33,4A
2031 DATA 26,EC,5C,C1,04
2032 DATA 26,E5,01,86,F7
2033 DATA 97,20,96,22,81
2034 DATA FD,27,06,81,FB
2035 DATA 27,0C,20,15,7D
2036 DATA 0A,41,27,10,7A
2037 DATA 0A,41,20,0B,B6
2038 DATA 0A,41,81,03,24
2039 DATA 03,7C,0A,41,01
2040 DATA 7D,0A,43,26,14
2041 DATA 86,FB,97,20,96
2042 DATA 22,81,FD,01,26
2043 DATA 41,7C,0A,43,B6
2044 DATA 0A,41,B7,0A,42
2045 DATA 7C,0A,42,86,08
2046 DATA F6,0A,42,BD,0B
2047 DATA 50,A6,00,81,E4
2048 DATA 27,10,7E,0B,A4
2049 DATA 01,01,01,01,01
2050 DATA 01,7C,0A,40,86
2051 DATA 8F,20,0E,FC,0A
2052 DATA 4E,C3,00,0A,FD
2053 DATA 0A,4E,86,2A,7C
2054 DATA 0A,40,7C,0A,40
2055 DATA A7,00,7F,0A,43
2056 DATA 01,86,08,F6,0A
2057 DATA 41,BD,0B,50,A6
2058 DATA 00,81,E5,27,08
2059 DATA 25,02,20,09,7E
2060 DATA 0B,BE,01,86,03
2061 DATA B7,0A,40,86,E8
2062 DATA A7,00,4C,A7,01
2063 DATA FC,0A,4E,C3,00
2064 DATA 01,2A,03,83,80
2065 DATA 00,FD,0A,4E,39
2066 DATA 01,01,01,01,01
2067 DATA 01,36,37,36,86
2068 DATA 14,3D,18,33,3A
2069 DATA 18,F3,02,70,18
2070 DATA 33,32,39,01,01
2071 DATA 01,01,01,01,01
2072 DATA 08,10,20,10,08
2073 DATA 04,08,08,30,40
2074 DATA 40,30,08,04,02
2075 DATA 0C,10,08,08,04
2076 DATA 04,02,01,06,00
2077 DATA 28,1E,1E,28,00
2078 DATA 00,08,04,02,00
2079 DATA 00,00,10,10,28
2080 DATA 02,00,40,00,0B
2081 DATA 00,01,00,04,24
2082 DATA 34,74,78,34,24
2083 DATA 24,24,20,10,08
2084 DATA 25,07,86,E6,A7
2085 DATA 00,7E,0B,19,81
2086 DATA 20,27,F5,7E,0A
2087 DATA FB,18,83,00,13
2088 DATA 18,E7,00,C6,20
2089 DATA 39,81,20,26,03
2090 DATA 7E,0B,34,86,04
2091 DATA 7E,0B,31,00,10
2092 DATA 10,FC,10,40,00
2093 DATA 04,04,03,02,00
2094 DATA F8,20,20,FE,10
2095 DATA F0,0F,10,20,21
2096 DATA 24,27,00,00,84
2097 DATA 48,30,CC,30,00
2098 DATA 14,22,11,0F,00
2099 DATA 50,58,50,00,20
2100 DATA 00,1D,15,1D,20
2101 DATA 1C,FE,20,22,04
2102 DATA 80,40,03,0C,30
2103 DATA 00,07,08,40,C0
2104 DATA 40,40,80,00,08
2105 DATA 0F,00,08,07,00
2106 DATA 7C,54,FC,54,7C
2107 DATA 00,24,15,07,15
2108 DATA 24,00,20,FE,20
2109 DATA 22,04,00,17,20
2110 DATA 03,14,20,00,00
2111 DATA 20,24,24,E4,24
2112 DATA 10,0C,03,20,3F
2113 DATA 00,24,20,00,00
2114 DATA 20,10,03,0C,10
2115 DATA 00,00,24,A8,E6
2116 DATA AC,18,40,54,28
2117 DATA 1F,14,00,21,1A
2118 DATA 54,D4,7C,40,40
2119 DATA 00,40,7F,00,1A
2120 DATA 21,00,01,01,48 : REM 0C58 ... 0C5C
2121 DATA DONE
