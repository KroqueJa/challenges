#include "dir_node.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

dir_node* create_dir_node( const char* name )
{
  // check length of name
  unsigned name_len = strlen( name );
  // allocate memory for a new dir_node with room for 16 children
  dir_node* node = (dir_node*)malloc( sizeof( dir_node ) );
  char* p_dir_name = (char*)malloc( (name_len + 1) * sizeof( char ) );
  dir_node** p_children = (dir_node**)malloc( DEFAULT_CHILDREN_SZ * sizeof( dir_node* ) );
  strncpy( p_dir_name, name, name_len + 1 );
  node->visited= false;
  node->dir_size = 0;
  node->allocated_size = DEFAULT_CHILDREN_SZ;
  node->num_children = 0;
  node->dir_name = p_dir_name;
  node->children = p_children;
  return node;
}

void destroy_dir_node( dir_node* node )
{
  if ( node->num_children == 0 ) {
    free( node );
    return;
  }
  for ( int i = 0; i < node->num_children; ++i ) destroy_dir_node( node->children[i] );
}

void add_child( dir_node* parent, dir_node* child )
{
  if ( parent->num_children == parent->allocated_size ) {
    parent->allocated_size *= 2;
    parent->children = (dir_node**)realloc( parent->children, parent->allocated_size * sizeof( dir_node* ) );
    if ( parent->children == NULL ) {
      fprintf( stderr, "Memory reallocation failed\n" );
      exit( 1000 );
    }
  }
  parent->children[parent->num_children] = child;
  parent->num_children++;
  child->parent = parent;

}

