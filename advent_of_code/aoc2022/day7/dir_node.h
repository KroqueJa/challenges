#pragma once

#include <stdbool.h>

#define DEFAULT_CHILDREN_SZ 16
typedef struct dir_node {
  bool visited;
  unsigned long dir_size;
  unsigned allocated_size;
  unsigned num_children;
  char* dir_name;
  struct dir_node* parent;
  struct dir_node** children;
} dir_node;

dir_node* create_dir_node( const char* );
void destroy_dir_node( dir_node* );
void add_child( dir_node*, dir_node* );
