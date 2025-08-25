This exaple file contains two simple USR functions.
USR functions take one single parameter and usually return a result of the same type.

Note that it is posssible to change the type of the return value by writing a different type to the floating point accumulator type field FPTYP.

This example demonstrates
* passing an integer variable from BASIC and returning an integer result,
* embedding multiple USR functions in a single machine language module.

The assembler module contains these two USR functions:
* count the '1' bits in a 16-bit integer,
* rotate the the bits in a 16-bit integer left by 1, bit 15 ends up in bit 0.
