CC=gcc
CFLAGS=-c -g -ansi -Wall
# LDFLAGS=-lncurses  # Use on most linux systems
LDFLAGS=/home/zastre/seng265/assign4/ncurses/lib/libncurses.a  # Use for SENG labs machines

all: sched2textv

sched2textv: interface.o schedproc.o
	$(CC) interface.o schedproc.o -o sched2textv $(LDFLAGS)

interface.o: interface.c schedproc.h
	$(CC) $(CFLAGS) interface.c

schedproc.o: schedproc.c schedproc.h
	$(CC) $(CFLAGS) schedproc.c

clean:
	-rm -f sched2textv interface.o schedproc.o
