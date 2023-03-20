CC = gcc
CFLAGS = -std=c99
DEPS = dir_node.o

all: day7

day7: $(DEPS)
	$(CC) $(CFLAGS) $(DEPS) day7.c -o $@

dir_node.o:
	$(CC) $(CFLAGS) -c dir_node.c -o $@

.PHONY: clean all

clean:
	rm day7
	rm *.o
