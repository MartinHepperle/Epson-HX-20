I/O Magazine 12/1982

Translation of the Japanese text:

RANDOM BOX
HC-20 About VRAM addressing
Formosa Cheryl

VRAM Address
The HC-20 allows you to freely set the size of the virtual screen using the WIDTH statement.
Therefore, the VRAM address also changes according to this setting.
This time I only looked up the setting values that are likely to be used frequently.
If you want to use other values, please look them up yourself 
(the address starts with $3EF0 minus the number of characters should generally be used.

My HC-20 i version 0.C. and all umbers are from a cold start.

WIDTH	Top Left	Bottom Right
20 x 4	3EAB	3EFA
40 x 4	3E5B	3EFA
20 x 8	3E57	3EF6
40 x 8	3DB7	3EF6
20 x 25	3AFE	3EE5
80 x 25	3716	3EE5

Notice
Be sure to put POKE &H7E,&H80 at the beginning of your program (if you forget this, an "FC ERROR" will appear when you POKE into VRAM).
Even if you write data into VRAM, it will not be displayed unless you operate the screen.
So if your program only uses POKE, wrute PRINT CHR$(11) (home cursor) or use a similar screen control code to refresh the screen.

Game
Here is a sample of the "UFO Game". To play, press up and down to fire the beam.
Enjoy the speed that you can't get with PRINT.
Please reset all CLEAR statements, RAMFILE, etc. to their initial states before loading.

P.S. May E.S.C. prosper to the end!


Keys used: 
@ /   up down?
:

10 WIDTH 20,4:POKE &H7E,&H80
20 CLS:LOCATE 0,0,0
30 V=&H3EAB:X=2:X1=1:S=0
40 Y0=18:S1=0:Y=0
50 PRINT CHR$(11):POKE V+X*20+Y,32
60 X=X+INT(RND(1)*3)-1
70 Y=Y+INT(RND(1)*3)-1
80 GOSUB 360
90 IF X<0 THEN X=0
100 IF X>3 THEN X=3
110 IF Y<0 THEN Y=0
120 IF Y>13 THEN Y=13
130 POKE V+X*20+Y,64
140 GOSUB 160
150 GOTO 50
160 POKE V+X1*20+19,32
170 IN$=INKEY$
180 IF IN$="" THEN 200
190 IM$=INKEY$:IF IM$<>"" THEN 190
200 IF IN$="@" THEN IF X1>0 THEN X1=X1-1
210 IF IN$="/" THEN IF X1<3 THEN X1=X1+1
220 POKE V+X1*20+19,154
230 IF S=1 THEN GOSUB 260
240 IF S=0 THEN IF IN$=":" THEN S=1:X0=X1
250 RETURN
260 POKE V+X0*20+Y0,32:IF Y0=0 THEN S=0:Y0=18:RETURN
270 Y0=Y0-1
280 IF PEEK(V+X0*20+Y0)=64 THEN 310
290 POKE V+X0*20+Y,133
300 RETURN
310 POKE V+X*20+Y,42:PRINT CHR$(11)
320 SOUND 15,4
330 POKE V+X*20+Y,32
340 S=0
350 Y0=18:RETURN
360 IF RND(1)>.5 THEN IF S1=0 THEN S1=1:Y2=Y+1:X2=X
370 IF S1=0 THEN RETURN
380 POKE V+X2*20+Y2,32
390 Y2=Y2+1:X2=X2+INT(RND(1)*3)-1
400 IF X2<0 THEN X2=0
410 IF X2>3 THEN X2=3
420 IF Y2=20 THEN S1=0:RETURN
430 IF PEEK(V+X2*20+Y2)=154 THEN 460
440 IF PEEK(V+X2*20+Y2)=133 THEN 510
450 POKE V+X2*20+Y2,43:RETURN
460 SOUND 19,4
470 POKE V+X1*20+19,42:PRINT CHR$(11)
480 POKE V+X1*20+19,32
490 S1=0
500 RETURN
510 IF RND(1)>.5 THEN S1=0:RETURN
520 POKE V+X0*20+Y0,32:S=0:Y0=18:RETURN
