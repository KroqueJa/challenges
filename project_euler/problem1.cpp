#include <iostream>

using std::cout;
using std::endl;

int main(int argc, char** argv)
{
  if (argc  != 2) {
    cout << "Please enter an argument" << endl;
    exit(255);
  }

  unsigned limit = atoi(argv[1]);

  unsigned short i;
  unsigned sum = 0;

  for (i = 3; i < limit; i += 3)
    sum += i;

  for (i = 5; i < limit; i += 5) {
    if (i % 3 != 0)
      sum += i;

  }

  cout << sum << endl;
}
