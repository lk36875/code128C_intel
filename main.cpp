#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <regex>
#include <vector>
using namespace std;

extern "C" int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);

unsigned char *ReadBMP(char *filename, int &width, int &height)
{
  int i;
  std::fstream file;
  file.open(filename, std::fstream::binary | std::fstream::in);

  file.seekg(0, file.end);
  int length = file.tellg();
  file.seekg(0, file.beg);
  char *data = new char[length];
  file.read(data, length);

  width = *(int *)&data[18];
  height = *(int *)&data[22];
  auto headerOffset = *(int *)&data[10];

  unsigned char *pixels = new unsigned char[width * height * 3];
  file.seekg(headerOffset);
  file.read((char *)pixels, width * height * 3);

  file.close();
  return pixels;
}

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

  int width = 0;
  int height = 0;
  auto data = ReadBMP(filename_char, width, height);

  char ptext[] = "No code";
  unsigned char text[] = "nh:wind on the hill";
  int result;

  printf("Input string      > %s\n", ptext);
  result = Decode128(data, ptext, width, height, skanline);
  // printf("1After replace    > %s\n", data);
  cout << data << endl;
  cout << width << endl;
  cout << height << endl;
  printf("Count             > %x\n", result);

  ofstream myfile;
  myfile.open("output.txt");
  for (int i = 0; i < sizeof(data); i++)
  {
    myfile << data[i] << endl;
  }
  myfile.close();

  return 0;
}
