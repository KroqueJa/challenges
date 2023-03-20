#include "hashmap.h"
#include <stdint.h>
#include <stdio.h>

uint32_t hash( const char* s, size_t len ) {
    uint32_t h = 0;
    while ( len ) {
        h = 31 * h + *s++;
        --len;
    }
    return h;
}

// initializes a hashmap with `size` buckets
hashmap* hashmap_init( size_t size ) {
    hashmap* map = (hashmap*)malloc( sizeof( hashmap ) );
    map->lists = (list_node**)malloc( size * sizeof( list_node* ) );
    map->size = size;
    return map;
}

void hashmap_insert( hashmap* map, const char* data ) {
  uint32_t place = hash( data, map->size ) % map->size;
  create_list_node( data );

  if ( map->lists[place] == NULL ) {
    // no collision, create list node
    map->lists[place] = create_list_node( data );
  } else {
    // collision, insert
    list_insert( map->lists[place], data );
  }
}

void hashmap_find( hashmap* map, char* buffer, const char* data ) {
  uint32_t place = hash( data, map->size ) % map->size;
  list_find( map->lists[place], buffer, data );
}

void hashmap_destroy( hashmap* );
