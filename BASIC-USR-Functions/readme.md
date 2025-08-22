These directories contain simple examples for writing USR functions in machine language.
USR functions can take only one parameter. 

If you use string parameters, you can encapsulate multiple parameters into a single string, e.g. by concatenating bytes using the CHR$() function.


They use simple BASIC loaders with DATA and POKEM statements. Thius is simple and can be easily modified.
Of course, you can always convert the binary machine code data into an MLOAD format file for faster loading.
