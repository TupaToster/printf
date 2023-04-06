extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%b\nit work\n", 0x88);
    return 0;
}