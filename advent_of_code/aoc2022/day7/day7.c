#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "dir_node.h"

int main( int argc, char** argv ) 
{
  /* Read input file */

  if ( argc != 2 ) {
    fprintf( stderr, "Wrong number of arguments\n" );
    return 255;
  }
  unsigned long fsize;
  char* buffer;

  FILE* fp = fopen( argv[1], "rb" );
  if ( fp == NULL ) {
    fprintf( stderr, "Error opening file\n" );
    return 1;
  }
  fseek(fp, 0, SEEK_END);
  fsize = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  buffer = (char*)malloc( fsize + 1 );

  if (buffer == NULL) {
    fprintf( stderr, "Error allocating memory" );
    return 127;
  }

  fread( buffer, fsize, 1, fp );
  buffer[fsize] = '\0';

  fclose( fp );

  /* Solve the problem */
  char* it = buffer;

  it += 7;

  int len;
  char strbuf[64];
  while ( *it != '\0' ) {
    // are we on a command?
    if ( it[0] == '$' ) {
      if ( it[2] != 'c' ) {
        // skip `ls` commands, they are implicit
        while ( *it != '\n' && *it != '\0' ) ++it;
        continue;
      }
      // on a bona fide `cd` command, get the file name
      // after checking that it's not `..`
      it += 5; // skip '$ cd '
      len = 0;
      while ( *it != '\n' ) {
        ++len;
        ++it;
      }
      strncpy( strbuf, it-len, len+1 );
      printf( "%s\n", strbuf );
    }
    while ( *it != '\n' ) ++it;
  printf( "%s\n", it );
  ++it;
  }

  free( buffer );

  return 0;

}
