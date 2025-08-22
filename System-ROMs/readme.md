Some crude disassembly of some System ROMs.

Global Memory Map
-----------------
* E000-FFFF -- ROM 1: I/O Routines
* C000-DFFF -- ROM 2: Menu, Monitor
* A000-BFFF -- ROM 3: BASIC 1
* 8000-9FFF -- ROM 4: BASIC 2
* 6000-7FFF -- ROM 5: Option ROM or 8 KB extension RAM
* 4000-5FFF -- unused or 8 KB extension RAM
* 0000-3FFF -- 16 KB internal RAM and I/O ports

Notes:
------
The first Basic ROM, mapped into the memory range C000-DFFF, appears in two versions V1.0 and V1.1.
These versions differ, but here is no difference between the Japanese/US/UK systems and the European systems.

The second BASIC ROM, covering the range E000-FFFF, also exists in both versions V1.0 and V1.1 but these
also differ for the Japanese/US/UK and the European systems. 
