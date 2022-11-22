#include <stdio.h>  // printf, fopen, fclose, getline
#include <stdlib.h> // atoi

int main(int argc, char** argv)
{
  if (argc != 2) {
    printf("Please supply exactly one file name\n");
    return 255;
  }

  FILE* infile = fopen(argv[1], "r");
  char* line = NULL;
  size_t len = 0;
  ssize_t read;

  unsigned short prev, cur;
  unsigned sum  = 0;

  // get the first number
  read = getline(&line, &len, infile);
  prev = atoi(line);

  // read the rest of the numbers
  while ((read = getline(&line, &len, infile)) != -1) {
    cur = atoi(line);
    if (cur > prev)
      ++sum;
    prev = cur;
  }

  fclose(infile);
  printf("%d\n", sum);
}
