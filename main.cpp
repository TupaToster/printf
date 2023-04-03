extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%c", 'x');
    return 0;
}