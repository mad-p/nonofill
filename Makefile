# Makefile for nonofill
# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

SOLUTIONS = solutions.txt unique_solutions.txt solutions_kei.txt unique_solutions_kei.txt
CFLAGS = -O -Wall --std=c99
SRCS = *.pl *.pm *.c Makefile
ZIP = nonofill.zip

all: $(SOLUTIONS)
zip: $(ZIP)

solutions.txt: nonofill.txt print.pl
	perl print.pl nonofill.txt > $@

unique_solutions.txt: uniq.txt print.pl
	perl print.pl uniq.txt > $@

%_kei.txt: %.txt keisenize.pl
	perl keisenize.pl $< > $@

uniq.txt: nonofill.txt uniq.pl Omino.pm
	perl uniq.pl nonofill.txt > $@

$(ZIP): $(SRCS) $(SOLUTIONS)
	zip $@ $^

nonofill: nonofill.o
nonofill.o: nonofill.c nonopat.h

nonofill.txt: nonofill
	nonofill > nonofill.txt

nonopat.h: fliprotate.pl Omino.pm nonomino.h
	perl fliprotate.pl

nonomino.h: generate.pl Omino.pm
	perl generate.pl

clean:
	-rm -f *.txt *.h *.o nonofill
