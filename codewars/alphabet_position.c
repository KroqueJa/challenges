#include <stdlib.h>
#include <stdio.h>

/*
In this kata you are required to, given a string, replace every letter with its position in the alphabet.
If anything in the text isn't a letter, ignore it and don't return it.
`"a" = 1`, `"b" = 2`, etc.
Example
alphabet_position("The sunset sets at twelve o' clock.")
Should return 
"20 8 5 19 21 14 19 5 20 19 5 20 19 1 20 20 23 5 12 22 5 15 3 12 15 3 11"
( as a string )
*/

// Helper function to return the position in the alphabet
// Post submission note; using 'a', 'z', 'A' and 'Z' instead of the integers
// gives a less readable but more understandable solution
static inline unsigned short pos(const char* c)
{
  if ( *c >= 65 && *c <= 90 ) {
    // char is upercase - remove 64 to get alphabet position
    return *c - 64;
  } else if ( *c >= 97 && *c <= 122 ) {
    // char is lowercase - remove 32 to get into lowercase, then 64 as above
    return *c - 64 - 32;
  } else {
    // not in the alphabet
    return 0;
  }
}

// returned string has to be dynamically allocated and will be freed by the caller
char* alphabet_position(const char* text)
{
  // assume 256 chars is enough space
  char* result_str = (char*)malloc(256*sizeof(char));
  unsigned short p;
  size_t i = 0;
  size_t j = 0;
  
  while ( text[i] != '\0' ) {
    p = pos( &text[i++] );
    if ( p != 0 ) {
      if (p > 9) {
        // Two digits, write each to result string
        result_str[j++] = p / 10 + 48;
        result_str[j++] = p % 10 + 48;
      } else {
        // One digit, write to result string
        result_str[j++] = p + 48;
      }
    if ( text[i] != '\0' )
      result_str[j++] = 32;
    }
  }
  // deal with trailing spaces
  while ( result_str[--j] == 32 ) {}
  
  // end the result string
  result_str[++j] = '\0';
  return result_str;
}
