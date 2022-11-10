#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void reverseWords( char* text, char* out )
{

  unsigned i, j, k;
  i = 0;
  j = 0;
  while ( text[i] != '\0' ) {
    while ( text[j] != ' ' && text[j] != '\0' )
      ++j;

    k = j;
    while ( k != i ) {
      --k;
      out[i + j - k - 1] = text[k];
    }
    out[j] = text[j];
    i = j+1;
    ++j;
  }

}

int main( int argc, char** argv )
{
  if (argc != 2) {
    printf("Please provide one and only one argument\n");
    return 1;
  }

  // count number of required chars
  unsigned num_chars = 0;
  while ( argv[1][num_chars++] != '\0' ) {}

  // dynamically allocate that amount of memory
  char* input_buf = ( char* )malloc( num_chars * sizeof( char ) );
  char* output_buf = ( char* )malloc( num_chars * sizeof( char) );

  // copy the input argument into the input buffer
  strcpy( input_buf, argv[1] );

  // call the function to reverse the words in the input buffer
  reverseWords( input_buf, output_buf );

  printf( "%s\n", output_buf );

  // free the allocated memory
  free( output_buf );
  free( input_buf );
  return 0;
}
