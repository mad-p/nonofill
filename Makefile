# Makefile for nonofill
# Copyright (c) 2011 Kaoru Maeda
# kaoru.maeda@gmail.com

ANSWER = answers.txt unique_answers.txt
CFLAGS = -O -Wall -m64 --std=c99
SRCS = *.pl *.c Makefile
ZIP = nonofill.zip

$(ANSWER): uniq.pl printed.txt
	perl uniq.pl printed.txt
	head -1 $(ANSWER)

printed.txt: nonofill.txt nonoprint.pl
	perl nonoprint.pl nonofill.txt > $@

$(ZIP): $(SRCS) $(ANSWER)
	zip $@ $^

nonofill: nonofill.o
nonofill.o: nonofill.c nonopat.h

nonofill.txt: nonofill
	nonofill > nonofill.txt

nonopat.h: fliprotate.pl nonomino.h
	perl fliprotate.pl

nonomino.h: nono.pl
	perl nono.pl
