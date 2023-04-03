extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%c%c\n", 'X', 'Y');
    return 0;
}