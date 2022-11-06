
/*

In this kata, you are asked to square every digit of a number and concatenate them.
For example, if we run 9119 through the function, 811181 will come out, because 92 is 81 and 12 is 1.
Note: The function accepts an integer and returns an integer

*/

int square_digits(int num) {
  // No strings solution
  unsigned digit, square, result, pos;
  result = 0;
  pos = 1;
  while (num != 0) {
    digit = num % 10;
    square = digit * digit;
    result += square * pos;
    if (digit > 3) {
      // squared is two digits
      pos *= 100;
    } else {
      // squared is only one digit
      pos *= 10;
    }
    num /= 10;
  }
  return result;
}
