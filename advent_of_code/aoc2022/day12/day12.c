#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <math.h>

unsigned u_min (unsigned x, unsigned y) { return (x < y ? x : y); }

unsigned search( char* char_grid, unsigned* checked, char previous_height, 
    unsigned height, unsigned width,
    unsigned row, unsigned col,
    unsigned goal_row, unsigned goal_col,
    unsigned steps )
{

    // if we are out of bounds, return UINT_MAX
    if ( row < 0 || col < 0 || row >= height || col >= width ) return UINT_MAX;

    // keep track of the current index now that we know we are not out of bounds
    unsigned i = width * row + col;

    // if we've come here before with fewer steps, return UINT_MAX
    if ( checked[i] != 0 && checked[i] <= steps ) return UINT_MAX;

    // if the step here was illegal, return UINT_MAX
    if ( char_grid[i] - previous_height > 1 ) return UINT_MAX;

    // if we've found the goal, return how many steps it took to get here
    if ( row == goal_row && col == goal_col ) return steps;


    // mark current tile as visited
    checked[i] = steps;

    // search from any orthogonal squares
    return u_min (
      u_min(
        search( char_grid, checked, char_grid[i], height, width, row, col + 1, goal_row, goal_col, steps + 1 ), // search east
        search( char_grid, checked, char_grid[i], height, width, row, col - 1, goal_row, goal_col, steps + 1 )  // search west

        ),
      u_min(
        search( char_grid, checked, char_grid[i], height, width, row - 1, col, goal_row, goal_col, steps + 1 ), // search north
        search( char_grid, checked, char_grid[i], height, width, row + 1, col, goal_row, goal_col, steps + 1 )  // search south
        )
      );
}


int main(int argc, char** argv)
{

  // iterators
  unsigned i, j;

  // file pointer and input buffer for reading the input file
  FILE* f_in = fopen(argv[1], "r");
  char line[255];

  // get a line of input and count its width (including the newline)
  fgets( line, 255, f_in );
  unsigned width = 0;
  while ( line[++width] != '\0' ) ;

  // find total size of the file in bytes
  fseek( f_in, 0L, SEEK_END );
  unsigned input_size_bytes = ftell( f_in );
  unsigned height = input_size_bytes / width;

  // adjust the width to account for the newline
  --width;

  // allocate space for the grids
  char* char_grid = (char*)malloc( height * width * sizeof(char) );
  unsigned* checked = (unsigned*)calloc( height * width, sizeof(unsigned) );

  // read the input into the grid
  i = 0;
  fseek( f_in, 0L, SEEK_SET );
  while ( fgets( line, 255, f_in ) != NULL )
    memcpy( char_grid + width * i++, line, width );

  // close the file
  fclose(f_in);

  // find the coordinates of the goal square
  i = 0;
  while ( char_grid[i] != 'E' ) ++i;

  unsigned goal_row = i / width;
  unsigned goal_col = i % width;

  // replace the height of the goal square with 'z'
  char_grid[i] = 'z';

  // find the coordinates of the starting square
  i = 0;
  while ( char_grid[i] != 'S' ) ++i;

  unsigned start_row = i / width;
  unsigned start_col = i % width;

  // replace the height of the starting square with 'a'
  char_grid[i] = 'a';

  // solve part 1
  unsigned path_length = search( char_grid, checked, 'a', height, width, start_row, start_col, goal_row, goal_col, 0 );

  printf( "Part 1: %u\n", path_length );

  // solve part 2
  unsigned shortest_path_length = UINT_MAX;
  unsigned shortest_start_row, shortest_start_col;

  for ( i = 0; i < width * height; ++i ) {
    start_row = i / width;
    start_col = i % width;
    if ( char_grid[i] == 'a' ) {
      path_length = search( char_grid, checked, 'a', height, width, start_row, start_col, goal_row, goal_col, 0 );
      if ( path_length < shortest_path_length ) {
        shortest_path_length = path_length;
        shortest_start_row = start_row;
        shortest_start_col = start_col;
      }
    }
  }

  printf( "Part 2: %u\n", shortest_path_length );

  // clean up memory
  free( char_grid );

}
