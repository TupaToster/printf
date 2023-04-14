extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%o\n%x\n%b\n%d\n\nlol\n", 0xB6DB6DB6, 0xABCDEF, 0b101010101, 123456789);
    return 0;
}