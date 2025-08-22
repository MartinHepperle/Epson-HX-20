Useful tools for assembler programming for the HX-20

<b>a09</b> - assembler suitable of assembling 6301 machine language binaries, outputs listings, binaries and srec files<br>
   see https://github.com/Arakula/A09<br>
<b>f9dasm</b> - disassembler with 6301 option<br>
   see https://github.com/Arakula/f9dasm<br>
<b>sim6301</b> - simulator for 6301, reads SREC files<br>
   see https://github.com/dg1yfe/sim68xx<br>


Cross-Assembling for the HX-20
==============================
While it is possible to use the MONITOR to input machine language programs as HEX codes.
Alternatively, HX-20 based assemblers can be used to create machine language programs.
However, the available editing and debugging functions are somewhat limited and coding
errors may quickly lead to overwriting important memory locations.
Such errors usually require re-initializing the HX-20 and thus lead to a loss of all current programs.

Therefore, I found it desirable to test machine language routines on a PC before actually testing
them on the real hardware.

The following process allows me to test parameter passing, algorithms and return of results.
It does not allow testing procedures which use HX-20 ROM functions or system memory locations, though.
For this purpose, dummy functions could be added, but so far I did not need that.

My procedure goes like this:

1) Write the assembler routine
   any-text-editor file.asm

2) Assemble into machine code, write a LST (for LST2BAS.py) and an SREC file (for sim6301)
   a09 file.asm -Sfile.srec -Lfile.lst

3) Load and test the program with sim6301 (source at https://...) This simulator reads files in Motorola's SREC format.
   sim6301.exe file.srec

   Note that sim6301 itself provides no HX-20-specific functions. Nevertheless, 
   it is quite useful for the testing algorithms.
   For BASIC-callable USR routines a short pseudo parameter passing stub can be 
   added to simulate accessing BASIC variables before calling the function.
   One could think of adding symbols and load some ROM fragments for system routines to make the disassembly more readable, though.

5) If the test was successful, translate the listing file without the dummy parameters into a BASIC program
   with DATA statements and a HEX byte loader.
   python LST2BAS.py file.lst > file.bas


	
Example: debugging stringrev.asm
================================
This example contains BASIC callable USR functions, so that we have to set up
some pseudo parameters for testing.
In case of the string reversal function we have to prepare a pseudo string 
parameter according to the HX-20 manual.
This and its associated data can be enclosed in conditional IFD blocks,
so that debugging can be activated by defined a symbol in the assembler
source or on the command line.

Assembling and the generation of a Motorola SREC file can then 
be performed by:

<code>D:\Epson HX-20\ASM>a09 stringrev.asm  -DDEBUG_STR -Lstringrev.lst -Sstringrev.srec</code>

The simulator is executed by:

<code>D:\Epson HX-20\ASM>sim6301 stringrev.srec</code>

Besides producing an SREC file we can also write a SYMBOL file
"stringrev.sym". This file contains two entries per line: the
symbol name and its hexadecimal address, separated by a blank.
sim6301 is not very sophisticated, but at least the additional
display of the symbol names when the address is used helps a
bit. In our test case it may contain these lines:

<code>DEBUG_STR 0038
EXITSUB 0A77
HEAD 0A78
MEMSET 0A81
NEXT 0A5A
NOCARRY 0A59
NOCARRY2 0A72
REVSTR 0A45
STRDESC 0A7A  
STRSPACE 0A7D</code>

After the simulator has loaded the binary, it lists the current
values of all CPU registers and the first instruction at the current PC.

<code>D:\Epson HX-20\ASM>sim6301.exe stringrev.srec
Warning: sp:0000, max:00ff
PC=0a40 A:B=0000 X=0000 SP=f000 CCR=d0(11hInzvc)        [0]
0a40    86 03           ldaa #03</code>

Note:
I have hard-coded the start address of 0A40 into my version of sim6301
as this is the most common for HX-20 BASIC routines. 
One can also set any register e.g. PC with the "r" command like "r pc 8000"
if your code as a different origin. sim6301 also has a command line option
to read a command file with such presets, if you wish.

We can unassemble memory to make sure that everything has been loaded correctly.

<code>>u a40 1B
0a40    86 03           ldaa #03
0a42    ce 0a 7a        ldx  #0a7a      STRDESC
0a45    81 03           cmpa #03
0a47    26 2e           bne  2e
0a49    e6 00           ldab 00,x
0a4b    ee 01           ldx  01,x
0a4d    ff 0a 78        stx  0a78       HEAD
0a50    b6 0a 78        ldaa 0a78       HEAD
0a53    fb 0a 79        addb 0a79
0a56    24 01           bcc  01
0a58    4c              inca
0a59    18              xgdx
0a5a    09              dex
0a5b    bc 0a 78        cpx  0a78       HEAD
0a5e    2b 17           bmi  17
0a60    e6 00           ldab 00,x
0a62    3c              pshx
0a63    fe 0a 78        ldx  0a78       HEAD
0a66    a6 00           ldaa 00,x
0a68    e7 00           stab 00,x
0a6a    7c 0a 79        inc 0a79
0a6d    24 03           bcc  03
0a6f    7c 0a 78        inc 0a78        HEAD
0a72    38              pulx
0a73    a7 00           staa 00,x
0a75    20 e3           bra  e3
0a77    39              rts</code>

Now that everything looks good, we can step through the code by
using the "t"race command:

<code>>t
PC=0a42 A:B=0300 X=0000 SP=f000 CCR=d0(11hInzvc)        [2]
0a42    ce 0a 7a        ldx  #0a7a      STRDESC</code>

<code>>t
PC=0a45 A:B=0300 X=0a7a SP=f000 CCR=d0(11hInzvc)        [5]
0a45    81 03           cmpa #03</code>

<code>>t
PC=0a47 A:B=0300 X=0a7a SP=f000 CCR=d4(11hInZvc)        [7]
0a47    26 2e           bne  2e</code>

The simulator stops after each instruction so that we can view 
the current registers as well as the memory by using the "md" 
memory dump command:

<code>>md a7a 20
0a7a    04 0a 7d 41 42 43 44 ff ff ff ff ff ff ff ff ff  ..}ABCD.........
0a8a    ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................</code>


The memory dump shows the dummy string descriptor created for debugging
at 0a7a (1 byte string length followed by the 16-bit address of the string in
the string space (here: 0a7d). Looking at the string we read "ABCD".

We can now step through the character interchange loop or, assuming that
the code is correct, we can also set a breakpoint at the RTS instruction:

<code>>b a77
Breakpoint at 0a77 set</code>

List all active breakpoints to make sure it is really set:

<code>>b
Active breakpoints:
        0a77    EXITSUB</code>
  
Then we can run the code starting at the current PC:

<code>>g
0a47: Running...
Breakpoint before code execution, address 0a77!
Subroutine: 0000
PC=0a77 A:B=4243 X=0a7e SP=f000 CCR=f8(11HINzvc)        [148]
0a77    39              rts</code>

Inspecting memory again indeed shows that the characters in the string have been reversed.

<code>>md a7a 20
0a7a    04 0a 7d 44 43 42 41 ff ff ff ff ff ff ff ff ff  ..}DCBA.........
0a8a    ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff  ................</code>

We can now leave the simulator:

<code>>q</code>
<code>D:\Epson HX-20\ASM></code>
