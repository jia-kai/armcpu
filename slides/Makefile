img2bin: img2bin.cc
	g++ $< -o $@ -O2 -Wall -std=c++11 $(shell pkg-config --libs --cflags opencv)

clean:
	rm -f img2bin

.PHONY: clean
