# CC = gcc
CFLAGS = -Wall -g

all: diskinfo disklist diskget diskput

diskinfo: diskinfo.o
	$(CXX) $(CFLAGS) -o diskinfo diskinfo.o

disklist: disklist.o
	$(CXX) $(CFLAGS) -o disklist disklist.o

diskget: diskget.o
	$(CXX) $(CFLAGS) -o diskget diskget.o

diskput: diskput.o
	$(CXX) $(CFLAGS) -o diskput diskput.o

clean: 
	rm -rf diskinfo disklist diskget diskput diskinfo.o disklist.o diskget.o diskput.o
