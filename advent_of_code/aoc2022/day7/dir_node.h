#pragma once

#define DEFAULT_CHILDREN_SZ 16
typedef struct dir_node {
  unsigned long dir_size;
  unsigned allocated_size;
  unsigned num_children;
  char* dir_name;
  struct dir_node** children;
} dir_node;

dir_node* create_node( const char* );
void destroy_node( dir_node* );
void add_child( dir_node*, dir_node* );
