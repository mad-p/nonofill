CFLAGS = -O -Wall -m64 --std=c99

nonofill: nonofill.c nonopat.h

nonofill_answer.txt: nonofill.txt nonoprint.pl
	perl nonoprint.pl nonofill.txt > $@

nonofill.txt: nonofill
	nonofill | tee nonofill.txt

nonopat.h: fliprotate.pl nonomino.h
	perl fliprotate.pl

nonomino.h: nono.pl
	perl nono.pl
