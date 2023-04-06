extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%b\nit work\n%s\n\n", 0x88, "it work 2");
    return 0;
}