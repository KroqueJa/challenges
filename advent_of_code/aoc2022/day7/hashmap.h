#pragma once

#include <stdlib.h>
#include <stdint.h>

#include "linked_list.h"

typedef struct {
  size_t size;
  list_node** lists;
} hashmap;

uint32_t hash( const char*, size_t );
hashmap* hashmap_init( size_t );
void hashmap_insert( hashmap*, const char* );
void hashmap_find( hashmap*, char*, const char* );
void hashmap_destroy( hashmap* );
