This is a simple USR function.
USR functions take one single parameter and usually return a result of the same type.

Note that it is posssible to change the type of the return avlue by writing a different type to the floating point accumulator type FPTYP.

It demonstrates
* passing an integer variable from BASIC and returning the integer result,
* embedding mutliple USR function in a single machine language module.

The assembler module contains two USR functions:
The first counts the bits in a 16-bit integer, the second rotates the the bits in a 16-bit integer left by 1. 
