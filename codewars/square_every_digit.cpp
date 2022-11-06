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
