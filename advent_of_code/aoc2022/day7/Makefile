CC = gcc
CFLAGS = -std=c99
DEPS = dir_node.o linked_list.o hashmap.o

all: day7

day7: $(DEPS)
	$(CC) $(CFLAGS) $(DEPS) day7.c -o $@

dir_node.o:
	$(CC) $(CFLAGS) -c dir_node.c -o $@

hashmap.o:
	$(CC) $(CFLAGS) -c hashmap.c -o $@

linked_list.o:
	$(CC) $(CFLAGS) -c linked_list.c -o $@

.PHONY: clean all

clean:
	rm day7
	rm *.o
