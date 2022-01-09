#include <stdio.h>
#include <iostream>
#include <fstream>
#include <string>
#include <regex>
#include <stdexcept>
using namespace std;

extern "C" int Decode128(unsigned char *image, char *text, int xline, int yline, int skanline);

unsigned char *ReadBMP(char *filename, int &width, int &height)
{
  int i;
  std::fstream file;

  file.open(filename, std::fstream::binary | std::fstream::in);
  if (!file)
  {
    throw invalid_argument("File incorrect");
  }
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
    cout << "Required arguments: filename, line number\n";
    throw invalid_argument("You must pass 2 arguments");
  }

  string filename = argv[1];
  if (regex_match(filename, regex(".*\\.bmp")))
  {
    cout << filename << endl;
    cout << "Filename correct.\n";
  }
  else
  {
    throw invalid_argument("Format of file is wrong");
  }

  char filename_char[1024];
  std::strcpy(filename_char, filename.c_str());

  int width = 0;
  int height = 0;
  auto data = ReadBMP(filename_char, width, height);

  int skanline = stoi(argv[2]);
  if (skanline <= 1 || skanline >= (height - 1))
  {
    throw invalid_argument("Skanned line must be greater than 1 and lower than height - 1.");
  }

  char ptext[] = "                                       ";
  int result;
  result = Decode128(data, ptext, width, height, skanline);
  if (result == 0)
  {
    printf("Returned value : %d\n", result);
    printf("Code: %s\n", ptext);
    printf("Code read correctly.\n\n");
  }
  else if (result == 1)
  {
    throw runtime_error("Out of range error");
  }
  else if (result == 2)
  {
    throw runtime_error("Wrong space error");
  }
  else if (result == 3)
  {
    throw runtime_error("Wrong checksum error");
  }
  else if (result == 4)
  {
    throw runtime_error("Wrong stop error");
  }
  else if (result == 5)
  {
    throw runtime_error("Wrong pattern error");
  }

  return 0;
}
