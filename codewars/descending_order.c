#include <inttypes.h>  
#include<math.h>  
#include <stdio.h>

/*
Your task is to make a function that can take any non-negative integer as an argument and return it with its digits in descending order. Essentially, rearrange the digits to create the highest possible number.
Examples:

Input: 42145 Output: 54421
Input: 145263 Output: 654321
Input: 123456789 Output: 987654321

The first solution (so far) I'm pretty unhappy with; naive and overengineered at the same time.
*/

void insertion_sort(unsigned short* arr, const uint64_t n)
{
  // For very small arrays, insertion sort is the fastest sorting algorithm
  unsigned int i, j;
  unsigned short tmp;
  for (i = 1; i < n; ++i) {
    tmp = arr[i];
    j = i;
    while ( (j > 0) && (tmp < arr[j - 1]) ) {
      arr[j] = arr[j - 1];
      --j;
    }
    arr[j] = tmp;
  }
}

uint64_t descendingOrder(uint64_t n)
{
  if ( n < 10 )
    return n;
  
  uint64_t num_digits = log10(n)+1;
  unsigned short digits[num_digits];
  uint64_t pos = pow(10, num_digits - 1);
  uint64_t result = 0;
  short i = 0;
  while (pos != 0) {
    digits[i++] = (n / pos) % 10;
    pos /= 10;
  }
  
  insertion_sort(digits, num_digits);
  // The numbers are now sorted in ascending order; all we need to do is fit them back together
  pos = 1;
  for (i = 0; i < num_digits; ++i) {
    result += digits[i] * pos;
    pos *= 10;
  }

  return result;
}
