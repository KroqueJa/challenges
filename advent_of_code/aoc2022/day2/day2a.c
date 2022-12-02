#include <stdio.h>
#include <stdlib.h>
int main(int argc, char** argv)
{
  FILE* f_in = fopen(argv[1], "r");
  char line[6];

  unsigned char opp, me;
  char result;
  unsigned long long score = 0;
  while (fgets(line, 6, f_in) != NULL)
  {
    opp = line[0] - 64;
    me = line[2] - 87;
    result = me - opp;
    result += (result < 0) ? 3 : 0;

    score += 6*(result == 1) + 3*(result == 0) + me;

  }
  fclose(f_in);

  printf("%llu\n", score);
}
