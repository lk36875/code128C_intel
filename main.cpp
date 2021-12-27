#include <stdio.h>
#include <iostream>
#include <string>
#include <regex>
using namespace std;

extern "C" int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);

int main(int argc, char **argv)
{
  if (argc < 3)
  {
    printf("You must pass 2 arguments.\n");
    printf("filename, line number\n");
    return -1;
  }

  string filename = argv[1];
  if (regex_match(filename, regex(".*\\.bmp")))
  {
    cout << filename << endl;
    printf("Filename read correctly.\n");
  }
  else
  {
    return -1;
  }

  int skanline = stoi(argv[2]);
  if (skanline < 0)
  {
    printf("Skanned line must be greater than 0.\n");
    return -1;
  }

  char ptext[] = "pusty";
  unsigned char text[] = "nh:wind on the hill";
  int result;

  printf("Input string      > %s\n", text);
  result = Decode128(text, ptext, 50, 600, 33);
  printf("1After replace    > %s\n", text);
  printf("Count             > %d\n", result);

  return 0;
}
