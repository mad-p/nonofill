ANSWER = nonofill_answer.txt
CFLAGS = -O -Wall -m64 --std=c99
SRCS = *.pl *.c Makefile
ZIP = nonofill.zip

$(ANSWER): nonofill.txt nonoprint.pl
	perl nonoprint.pl nonofill.txt > $@

$(ZIP): $(SRCS)
	zip $@ $^

nonofill: nonofill.o
nonofill.o: nonofill.c nonopat.h

nonofill.txt: nonofill
	nonofill | tee nonofill.txt

nonopat.h: fliprotate.pl nonomino.h
	perl fliprotate.pl

nonomino.h: nono.pl
	perl nono.pl
