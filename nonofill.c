#include <stdio.h>
#include <stdlib.h>

typedef unsigned long long PAT;
#define BOARD 0xff818181818181ffull
#define SIZE 6

typedef struct mino {
  PAT pat;
  int width;
  int height;
} MINO;

MINO nonominos[] = {
#include "nonopat.h"
  {0,0,0}
};

void print_answer(PAT *minos) {
  PAT all = minos[0]| minos[1]| minos[2]| minos[3];
  printf("%016llx %016llx %016llx %016llx %d\n", minos[0], minos[1], minos[2], minos[3],
	 all == (0xffffffffffffffffull & ~BOARD));
  fflush(stdout);
}

void try(const MINO *begin, const MINO *end, int vshift, int hshift, PAT *minos, int depth) {
  /* got one answer */
  if (depth == 4) {
    print_answer(minos);
    return;
  }

  PAT fixed = BOARD;
  for (int i = 0; i < depth; i++) {
    fixed |= minos[i];
  }

  for (const MINO *p = begin; p < end; p++) {
    int start_vs = p == begin ? vshift : 0;
    for (int vs = start_vs; vs <= SIZE - p->height; vs++) {
      int start_hs = p == begin && vs == vshift ? hshift : 0;
      for (int hs = start_hs; hs <= SIZE - p->width; hs++) {
	PAT current = p->pat >> (8 * vs + hs);
	// printf("pat = %016llx; vs=%d; hs=%d; current = %016llx\n", p->pat, vs, hs, current);
	if ((fixed & current) == 0) {
	  /* can put here */
	  minos[depth] = current;
	  /* recurse one level */
	  try(p, end, vs, hs, minos, depth + 1);
	}
      }
    }
  }
}

void try_mino() {
  int no = 0;
  const MINO *begin = nonominos;

  while (begin->pat) {
    printf("# try %d\n", ++no);
    fflush(stdout);
    const MINO *end = begin;
    while (end->pat) end++;
    PAT minos[4];
    try(begin, end, 0, 0, minos, 0);
    begin = end + 1;
    /*exit(0);*/
  }
}

int main(int argc, char**argv) {
  try_mino();
}
