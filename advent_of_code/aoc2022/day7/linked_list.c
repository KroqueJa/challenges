#include "linked_list.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

list_node* create_list_node( const char* data ) {
  size_t len = 0;
  const char* it = data;
  while ( *it++ != '\0' ) {}
  len = it - data;
  char* p_data = (char*)malloc( len*sizeof( char ) );
  list_node* node = (list_node*)malloc( sizeof( list_node ) );
  strncpy( p_data, data, len );
  node->data = p_data;
  node->next = NULL;
  return node;
}

void list_insert( list_node* root, const char* data ) {
  list_node* it = root;
  while ( it->next != NULL ) it = it->next;
  it->next = create_list_node( data );

}

void list_destroy( list_node* root ) {
  if ( root->next != NULL ) list_destroy( root->next );
  free( root->data );
  free( root );
}

void list_find( list_node* root, char* buffer, const char* data ) {
  size_t len;
  char* it;
  do {
    if ( strcmp( root->data, data ) == 0 ) {
      it = root->data;
      while ( *it != '\0' ) ++it;
      len = it - root->data;
      strncpy( buffer, root->data, len );
      return;
    } else {
      root = root->next;
    }
  } while ( root != NULL );
  // list does not contain element, clear buffer
  memcpy( buffer, "\0", 1 );
}
