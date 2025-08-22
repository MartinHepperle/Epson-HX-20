A primitive example for writing and installing device drivers.

Implements a simple device "BUF0:" which stores all bytes written to it in a ring buffer.
Reading from the device returns the bytes written until the buffer is empty.

The LOF() function returns the amount of data currently in the buffer.

The EOF() function returns 0 if there is something in the buffer, -1 otherwise.

The driver is installed in low memeory below the BASIC program text area.
