// #include "ascii.h"
#include "uart.h"
// #include "string.h"
// #include "memory_map.h"

int main(void)
{
    char msg[] = "HELLO WORLD!!";

    for (int i = 0; i < 13; i++) {
        uwrite_int8(msg[i]);
    }

    msg[4] = 'B';
    msg[5] = 'C';
    msg[6] = 'D';
    msg[7] = 'E';

    for (int i = 0; i < 13; i++) {
        uwrite_int8(msg[i]);
    }

    // int y = x + 500;

    // unsigned int t = 1000;

    //unsigned int r = 0xFFFFFFFF - t;

    //char m = msg[3];

    // char b = msg[4];
    // char c = msg[5];
    // char d = msg[6];
    // char e = msg[7];

    return 0;
}
