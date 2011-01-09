/*
 * Fill 6x6 board with four of the same nonomino
 *
 * Copyright (c) 2011 Kaoru Maeda
 * kaoru.maeda@gmail.com
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef unsigned long long PAT;
#define BOARD 0xff818181818181ffull
#define SIZE 6
#define MAX_ANSWER 100

typedef struct mino {
  PAT pat;
  int width;
  int height;
} MINO;

MINO nonominos[] = {
#include "nonopat.h"
  {0,0,0}
};

PAT answers[MAX_ANSWER][4];
int nanswers = 0;

int comp(const PAT *a, const PAT *b) {
  if (*a < *b) return -1;
  if (*a > *b) return 1;
  return 0;
}

void print_answer(const PAT *minos) {
  // remove permutation redundancy and print
  PAT sorted[4];
  memcpy(sorted, minos, sizeof(sorted));
  heapsort(sorted, 4, sizeof(sorted[0]), (int(*)(const void*,const void*))comp);

  for (int i=0; i<nanswers; i++) {
    if (memcmp(answers[i], sorted, sizeof(sorted)) == 0) {
      return;
    }
  }
  // ok, it's new
  memcpy(answers[nanswers], sorted, sizeof(sorted));
  printf("%016llx %016llx %016llx %016llx\n", sorted[0], sorted[1], sorted[2], sorted[3]);
  if (++nanswers >= MAX_ANSWER) {
    fprintf(stderr, "Too many answers found\n");
    exit(1);
  }
  fflush(stdout);
}

void try(const MINO *begin, const MINO *end, PAT *minos, int depth) {
  if (depth == 4) {
    // got an answer
    print_answer(minos);
    return;
  }

  PAT fixed = BOARD;
  for (int i = 0; i < depth; i++) {
    fixed |= minos[i];
  }

  for (const MINO *p = begin; p < end; p++) {
    for (int v = 0; v <= SIZE - p->height; v++) {
      for (int h = 0; h <= SIZE - p->width; h++) {
	// vertical   translation == 8 bit right shift
	// holizontal translation == 1 bit right shift
	PAT current = p->pat >> (8 * v + h);
	if ((fixed & current) == 0) {
	  // can put here
	  minos[depth] = current;
	  // recurse one level
	  try(p, end, minos, depth + 1);
	}
      }
    }
  }
}

void try_mino() {
  int no = 0;
  const MINO *begin = nonominos;

  while (begin->pat) {
    nanswers = 0;

    const MINO *end = begin;
    while (end->pat) end++;
    PAT minos[4];
    try(begin, end, minos, 0);

    no++;
    if (nanswers > 0) {
      fprintf(stderr, "# nonomino %d : %d\n", no, nanswers);
      fflush(stderr);
      fprintf(stdout, "# nonomino %d : %d\n", no, nanswers);
      fflush(stdout);
    }
    begin = end + 1;
  }
}

int main(int argc, char**argv) {
  try_mino();
}
