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

  char filename_char[1024];
  strcpy(filename_char, filename.c_str());
  int i;
  FILE *f = fopen(filename_char, "rb");
  unsigned char info[54];
  // header
  fread(info, sizeof(unsigned char), 54, f);
  // height and width
  int width = *(int *)&info[18];
  int height = *(int *)&info[22];
  // allocate 3 bytes per pixel
  int size = 3 * width * height;
  unsigned char *data = new unsigned char[size];
  // read the rest of the data
  fread(data, sizeof(unsigned char), size, f);
  fclose(f);

  char ptext[] = "No code";
  unsigned char text[] = "nh:wind on the hill";
  int result;

  printf("Input string      > %s\n", ptext);
  result = Decode128(data, ptext, width, height, skanline);
  printf("1After replace    > %s\n", data);
  printf("Count             > %d\n", result);

  return 0;
}
