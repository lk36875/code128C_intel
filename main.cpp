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

  int skanline = stoi(argv[2]);
  if (skanline < 0)
  {
    throw invalid_argument("Skanned line must be greater than 0.");
  }

  char filename_char[1024];
  std::strcpy(filename_char, filename.c_str());

  int width = 0;
  int height = 0;
  auto data = ReadBMP(filename_char, width, height);

  char ptext[] = "No code";
  unsigned char text[] = "nh:wind on the hill";
  int result;

  cout << "Input string " << ptext << endl;
  result = Decode128(data, ptext, width, height, skanline);
  // cout << data << endl;
  // cout << width << endl;
  // cout << height << endl;
  // cout << "Count: " << result << endl;
  printf("Count      num     > %d\n", result);
  printf("Count      hex     > %x\n", result);

  // ofstream myfile;
  // myfile.open("output.txt");
  // for (int i = 0; i < sizeof(data); i++)
  // {
  //   myfile << data[i] << endl;
  // }
  // myfile.close();

  return 0;
}
