This example implements a simple device "STAT:" which counts the occurrence of bytes written to it. The byte counters are 16-bit wide.

Reading from the device returns the occurances in form of high/low byte pairs until all 256 byte pairs have been read.

The LOF() function returns always 2 (2 bytes to read).

The EOF() function returns 0 if there is something to read, -1 otherwise.
