extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%b\nit work\n%o%%\n\n", 0x88, 01234);
    return 0;
}