#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "linked_list.h"
#include "dir_node.h"
#include "hashmap.h"

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
  /*
  char* it = buffer;
  int num;
  dir_node* root = create_node( "/" );
  dir_node* pwd = root;

  it += 7;

  int len;
  char strbuf[64];
  while ( *it != '\0' ) {
    // are we on a command?
    if ( it[0] == '$' ) {
      if ( it[2] != 'c' ) {
        // `ls`, we set the node to visited
        pwd->visited = true;
        printf( "ls, setting to visited\n" );
      } else if ( it[5] == '.' ) {
        // it is, go up one directory
        pwd = pwd->parent;
        printf( "Going up, present directory is %s\n", pwd->dir_name );
      } else {
        // if not, get the folder name
        it += 5; // skip '$ cd '
        len = 0;
        while ( *it != '\n' ) {
          ++len;
          ++it;
        }
        strncpy( strbuf, it-len, len );
        printf( "Descending into %s\n", strbuf );
      }
    } else {
      // This line contains information about the current directory
      if ( *it == 'd' ) {
        it += 4;
        len = 0;
        while ( *it != '\n' ) {
          ++len;
          ++it;
        }
        strncpy( strbuf, it-len, len );
        printf( "Found directory %s, creating if unknown\n", strbuf );
      } else {
        num = atoi( it );
        printf( "Found %d, adding to pwd total\n", num );
      }
    }
    // skip to the next command
    while ( *it != '\n' && *it != '\0' ) ++it;
    if ( *it == '\n' ) ++it;
  }
*/
  char strbuf[64];
  hashmap* map = hashmap_init( 1 );
  hashmap_insert( map, "stanky" );
  hashmap_insert( map, "klanky" );
  hashmap_insert( map, "pajas" );
  hashmap_find( map, strbuf, "klanky" );
  printf( "%s\n", strbuf );
  free( buffer );

  return 0;

}
