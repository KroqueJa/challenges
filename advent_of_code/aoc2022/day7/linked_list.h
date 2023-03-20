#pragma once

typedef struct list_node {
  char* data;
  struct list_node* next;
} list_node;

list_node* create_list_node( const char* );
void list_insert( list_node*, const char* );
void list_find( list_node*, char*, const char* );
void list_destroy( list_node* );
