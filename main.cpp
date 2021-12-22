#include <stdio.h>

extern "C" int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);

int main(void)
{
  char ptext[] = "pusty";

  unsigned char text[] = "nh:wind on the hill";
  int result;

  printf("Input string      > %s\n", text);
  result = Decode128(text, ptext, 2, 2, 2);
  printf("1After replace    > %s\n", text);
  printf("Count             > %d\n", result);

  return 0;
}
