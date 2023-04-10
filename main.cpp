extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%b\nit work\n%o%%\n\n", 0x88, 01234);
    int a = 0;
    a += 14;
    printf ("\n\n\n%d\n\nlol", a);
    return 0;
}