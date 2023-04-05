extern "C" void _printf (const char* fmt, ...);
#include <stdio.h>

int main () {

    _printf ("%c-%c = %c\nlol\n\n", 'a', 'b', '0');
    return 0;
}