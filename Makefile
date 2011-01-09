# Makefile for nonofill
# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

SOLUTIONS = solutions.txt unique_solutions.txt
CFLAGS = -O -Wall -m64 --std=c99
SRCS = *.pl *.pm *.c Makefile
ZIP = nonofill.zip

all: $(SOLUTIONS)
zip: $(ZIP)

solutions.txt: nonofill.txt nonoprint.pl
	perl nonoprint.pl nonofill.txt > $@

unique_solutions.txt: uniq.txt nonoprint.pl
	perl nonoprint.pl uniq.txt > $@

uniq.txt: nonofill.txt uniq.pl Mino.pm
	perl uniq.pl nonofill.txt > $@

$(ZIP): $(SRCS) $(SOLUTIONS)
	zip $@ $^

nonofill: nonofill.o
nonofill.o: nonofill.c nonopat.h

nonofill.txt: nonofill
	nonofill > nonofill.txt

nonopat.h: fliprotate.pl Mino.pm nonomino.h
	perl fliprotate.pl

nonomino.h: nono.pl Mino.pm
	perl nono.pl

clean:
	-rm -f *.txt *.h *.o nonofill
