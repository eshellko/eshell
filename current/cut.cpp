#include "stdio.h"

void print_int(FILE* w, unsigned int data)
{
   fprintf(w, "%c%c%c%c", data, data >> 8, data >> 16, data >> 24);
}

void print_int3(FILE* w, unsigned int data1, unsigned int data2, unsigned int data3)
{
   print_int(w, data1);
   print_int(w, data2);
   print_int(w, data3);
}

void print_char(FILE* w, unsigned char data)
{
   fprintf(w, "%c", data);
}

int main()
{
   FILE* w = fopen("bin/cut.bin", "wb");
   if(!w) return 1;

//
// 1-hot 5-inputs - AND between all of them, w.r.t. invertions
// 1-cold 5 inputs - implement with final invertion
//
   for(unsigned int i = 0 ; i < 32; i++)
   {
      unsigned int rv = 1U << i;
      //
      // 1-hot
      //
      print_int(w, rv);
      print_int(w, 5);
      print_int(w, 9);
      // Note: reorder is left to 'balance' / search of pre-exist combinations (TODO: single step, which clusters logic and finds exist pairs)
      print_int(w, 0); print_int(w, 1); print_int(w, 0 + ((i & 0x1) ? 0 : 1) + ((i & 0x2) ? 0 : 2));
      print_int(w, 2); print_int(w, 3); print_int(w, 0 + ((i & 0x4) ? 0 : 1) + ((i & 0x8) ? 0 : 2));
      print_int(w, 4); print_int(w, 5); print_int(w, 0 + ((i & 0x10) ? 0 : 1));
      print_int(w, 6); print_int(w, 7); print_int(w, 0);
      //
      // 1-cold
      //
      rv = ~rv;
      print_int(w, rv);
      print_int(w, 5);
      print_int(w, 9);
      print_int(w, 0); print_int(w, 1); print_int(w, 0 + ((i & 0x1) ? 0 : 1) + ((i & 0x2) ? 0 : 2));
      print_int(w, 2); print_int(w, 3); print_int(w, 0 + ((i & 0x4) ? 0 : 1) + ((i & 0x8) ? 0 : 2));
      print_int(w, 4); print_int(w, 5); print_int(w, 0 + ((i & 0x10) ? 0 : 1));
      print_int(w, 6); print_int(w, 7); print_int(w, 4); // invert final result
   }
//
// 1-hot, 4-inputs
// 1-cold, 4-inputs
//
   for(unsigned int i = 0 ; i < 16; i++)
   {
      unsigned int rv = (1U << i) + (1U << (i+16));
      print_int(w, rv);
      print_int(w, 4);
      print_int(w, 7);
      print_int(w, 0); print_int(w, 1); print_int(w, 0 + ((i & 0x1) ? 0 : 1) + ((i & 0x2) ? 0 : 2));
      print_int(w, 2); print_int(w, 3); print_int(w, 0 + ((i & 0x4) ? 0 : 1) + ((i & 0x8) ? 0 : 2));
      print_int(w, 4); print_int(w, 5); print_int(w, 0);

      rv = ~rv;
      print_int(w, rv);
      print_int(w, 4);
      print_int(w, 7);
      print_int(w, 0); print_int(w, 1); print_int(w, 0 + ((i & 0x1) ? 0 : 1) + ((i & 0x2) ? 0 : 2));
      print_int(w, 2); print_int(w, 3); print_int(w, 0 + ((i & 0x4) ? 0 : 1) + ((i & 0x8) ? 0 : 2));
      print_int(w, 4); print_int(w, 5); print_int(w, 4); // invert final
   }
//
// 1-hot, 3-inputs
// 1-cold, 3-inputs
//
   for(unsigned int i = 0 ; i < 8; i++)
   {
      unsigned int rv = (1U << i) + (1U << (i+8)) + (1U << (i+16)) + (1U << (i+24));
      print_int(w, rv);
      print_int(w, 3);
      print_int(w, 5);
      print_int(w, 0); print_int(w, 1); print_int(w, 0 + ((i & 0x1) ? 0 : 1) + ((i & 0x2) ? 0 : 2));
      print_int(w, 2); print_int(w, 3); print_int(w, 0 + ((i & 0x4) ? 0 : 1));

      rv = ~rv;
      print_int(w, rv);
      print_int(w, 3);
      print_int(w, 5);
      print_int(w, 0); print_int(w, 1); print_int(w, 0 + ((i & 0x1) ? 0 : 1) + ((i & 0x2) ? 0 : 2));
      print_int(w, 2); print_int(w, 3); print_int(w, 4 + ((i & 0x4) ? 0 : 1)); // invert final
   }


//   Info: the reduced boolean expression 0xf7f7f7f7 in SOP form: [3 args][3 real args] ---0- ----0 --1--
// WTH!? why upper fails?
   print_int(w, 0xf7f7f7f7);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 0, 1, 4);
   print_int3(w, 3, 2, 7);













/*
//
// 5-cut pairs where [0] is DC
//
   for(unsigned int i = 0 ; i < 16; i++)
   {
      unsigned int rv = 3U << (2*i);
      print_int(w, rv);
      print_int(w, 5);
      print_int(w, 8);
      print_int(w, 1); print_int(w, 2); print_int(w, 0 + ((rv & 0x2) ? 0 : 1) + ((rv & 0x4) ? 0 : 2));
      print_int(w, 3); print_int(w, 4); print_int(w, 0 + ((rv & 0x8) ? 0 : 1) + ((rv & 0x10) ? 0 : 2));
      print_int(w, 5); print_int(w, 6); print_int(w, 0);
   }

// TODO: fill others as soon as they are detected in real designs...
// Q: reorder and make [aig_]simulation when rewrite is called, to not keep all of them? also slower runtime will be...
*/
   print_int(w, 0x88000000); // 11111 | 11011
   print_int(w, 5);
   print_int(w, 8);
   print_int3(w, 0, 1, 0);
   print_int3(w, 3, 4, 0);
   print_int3(w, 5, 6, 0);

   print_int(w, 0xf960f960); // Q: use single VARS function?
   print_int(w, 4); // pi_num
   print_int(w, 8); // tot_num
   print_int3(w, 0, 1, 8);
   print_int3(w, 2, 3, 8);
   print_int3(w, 4, 5, 0);
   print_int3(w, 6, 3, 8);

   print_int(w, 0xc8000000);
   print_int(w, 5); // pi_num
   print_int(w, 9); // tot_num
   print_int(w, 3); // na
   print_int(w, 4); // nb
   print_int(w, 0); // attr
   print_int(w, 2); // na
   print_int(w, 0); // nb
   print_int(w, 7); // attr
   print_int(w, 6); // na
   print_int(w, 1); // nb
   print_int(w, 0); // attr
   print_int(w, 5); // na
   print_int(w, 7); // nb
   print_int(w, 0); // attr

   print_int(w, 0x8000800);
   print_int(w, 4); // pi_num
   print_int(w, 7); // tot_num
   print_int(w, 0); // na
   print_int(w, 1); // nb
   print_int(w, 0); // attr
   print_int(w, 2); // na
   print_int(w, 3); // nb
   print_int(w, 1); // attr
   print_int(w, 4); // na
   print_int(w, 5); // nb
   print_int(w, 0); // attr

   print_int(w, 0xe4e4e4e4);
   print_int(w, 3); // pi_num
   print_int(w, 8); // tot_num
   print_int(w, 1); // na
   print_int(w, 2); // nb
   print_int(w, 0); // attr
   print_int(w, 0); // na
   print_int(w, 2); // nb
   print_int(w, 12); // attr
   print_int(w, 1); // na
   print_int(w, 2); // nb
   print_int(w, 8); // attr
   print_int(w, 4); // na
   print_int(w, 5); // nb
   print_int(w, 0); // attr
   print_int(w, 3); // na
   print_int(w, 6); // nb
   print_int(w, 7); // attr

// Minimal Form (with ~) = a~bde + a~bcd
// 4~310 + 4~321
   print_int(w, 0xc80000);
   print_int(w, 5); // pi_num
   print_int(w, 11); // tot_num
   print_int3(w, 4, 3, 2);
   print_int3(w, 1, 0, 0);
   print_int3(w, 2, 1, 0);
   print_int3(w, 5, 6, 0);
   print_int3(w, 5, 7, 0);
   print_int3(w, 8, 9, 7);
#ifdef __NONE__
#endif

// refactor cut [fbfbfbbf]: 19 cells
//Minimal Form (with ~) = ~a~b~c + bc + ac + ~d + e
//~4~3~2 + 32 + 42 + ~1 + 0
   print_int(w, 0xfbfbfbbf);
   print_int(w, 5); // pi_num
   print_int(w, 12); // tot_num
   print_int3(w, 0, 1, 5);
   print_int3(w, 3, 4, 7);
   print_int3(w, 2, 6, 0);
   print_int3(w, 2, 3, 3);
   print_int3(w, 4, 8, 1);
   print_int3(w, 5, 7, 7);
   print_int3(w, 10, 9, 7);


   print_int(w, 0xff9fdf9f);
   print_int(w, 5); // pi_num
   print_int(w, 12); // tot_num
// d'e' + de + c' + be' + bd + ab
// 1'0' + 10 + 2' + 30' + 31 + 43
   print_int3(w, 4, 3, 0); // 5
// 3'4' + 34 + 2' + 14' + 13 + 5
// 3'4' + 34 + 2' + 1(4' + 3) + 5
   print_int3(w, 1, 0, 5); // 6
// 3'4' + 34 + 2' + 16 + 5
   print_int3(w, 3, 6, 0); // 7
// 3'4' + 34 + 2' + 7 + 5
   print_int3(w, 1, 0, 12); // 8
// 8 + 2' + 7 + 5
   print_int3(w, 8, 2, 5); // 9
// 9 + 7 + 5
   print_int3(w, 5, 7, 7); // 10
   print_int3(w, 10, 9, 7);


/*
refactor cut [c8c8c8c8]: 17 cells
refactor cut [c8c8c8c8]: 17 cells
refactor cut [4400440]: 20 cells
refactor cut [4400440]: 18 cells
   Info: design 'fft_raw' has 636 (708) flops / 0 (0) latches / 36207 (37205) gates / 0 (0) tri-state buffer / 0 (0) loop breakers.
*/
// The reduced boolean expression 0x4040440 in SOP form: 32'10' + 4'3'210'

// TODO: debug!?? WTH? 1-st case does not work!!! inverted works...
   print_int(w, 0x4040440);
   print_int(w, 5); // pi_num
   print_int(w, 11+2); // tot_num
/*
                           // 32'10' + 4'3'210'
   print_int3(w, 1, 0, 2); // 32'5 + 4'3'25
   print_int3(w, 3, 2, 2); // 65 + 4'3'25
   print_int3(w, 3, 4, 3); // 65 + 725
   print_int3(w, 7, 2, 0); // 65 + 85
   print_int3(w, 6, 8, 7);
   print_int3(w, 9, 5, 0);
*/
   
   print_int3(w, 2, 4, 0); // 0 + 1' + 32 + 4'3'2' + 5
   print_int3(w, 2, 3, 0); // 0 + 1' + 6 + 4'3'2' + 5
   print_int3(w, 2, 3, 3); // 0 + 1' + 6 + 4'7 + 5
   print_int3(w, 4, 7, 1); // 0 + 1' + 6 + 8 + 5
   print_int3(w, 0, 1, 5); // 9 + 6 + 8 + 5
   print_int3(w, 8, 5, 7); // 9 + 6 + 10
   print_int3(w, 9, 6, 7); // 11 + 10
   print_int3(w, 10, 11, 3);

// The reduced boolean expression 0xfbfbfbbf in SOP form: 0 + 1' + 32 + 4'3'2' + 42

//The reduced boolean expression  in SOP form: 3'210' + 32'10'
   print_int(w, 0x4400440);
   print_int(w, 4); // pi_num
   print_int(w, 9); // tot_num
// 3'210' + 32'10'
   print_int3(w, 1, 0, 2); // 4
// 3'24 + 32'4
   print_int3(w, 3, 2, 1); // 5
// 54 + 32'4
   print_int3(w, 3, 2, 2); // 6
// 54 + 64
   print_int3(w, 5, 6, 7); //7
   print_int3(w, 4, 7, 0); //8

//The reduced boolean expression 0xc8c8c8c8 in SOP form: 10 + 21
   print_int(w, 0xc8c8c8c8);
   print_int(w, 3); // pi_num
   print_int(w, 5); // tot_num
// 10 + 21
   print_int3(w, 2, 0, 7);
   print_int3(w, 3, 1, 0);


/*
refactor cut [7c7c7c7c]: 14 cells
refactor cut [2e2e2e2e]: 13 cells
refactor cut [e2e2e2e2]: 13 cells
   Info: design 'fft_raw' has 636 (708) flops / 0 (0) latches / 36180 (37205) gates / 0 (0) tri-state buffer / 0 (0) loop breakers.
*/



/*
   print_int(w, 11); // tot_num
//~d~e + de + ab + ~c + bd
//~3~4 + 34 + 01 + ~2 + 13
   print_int(w, 3); print_int(w, 4); print_int(w, 12); // 5
   print_int(w, 0); print_int(w, 1); print_int(w, 0); // 6
   print_int(w, 1); print_int(w, 3); print_int(w, 0); // 7
   print_int(w, 7); print_int(w, 2); print_int(w, 5); // 8
   print_int(w, 5); print_int(w, 6); print_int(w, 7); // 9
   print_int(w, 8); print_int(w, 9); print_int(w, 7);
*/
/*   
   unsigned int minterm = 0xff9fdf9f;//fbbfbfbf; //strcpy(code, "X01XX X0X1X X100X");
QMC
d'e' + de + c' + be' + bd + ab

Minimal Form (with ~) =
~d~e + de + ab + ~c + b~e
~d~e + de + ab + ~c + bd
*/


   print_int(w, 0xffdfdfdf);
   print_int(w, 5);
   print_int(w, 9);
// e' + d + c' + ab
// 0' + 1 + 2' + 43
   print_int3(w, 3,4,0);
// 0' + 1 + 2' + 5
   print_int3(w, 0,1,6);
// 6 + 2' + 5
   print_int3(w, 2,5,6);
// 6 + 7
   print_int3(w, 6,7,7);

/*
   print_int(w, 0xdfffdff7);
   print_int(w, 5);
//The reduced boolean expression 0x20002008 in SOP form: bcd'e + a'b'c'de
   print_int(w, 12);
// ~  bcd'e + a'b'c'de
// ~  (bcd' + a'b'c'd)e
// ~  (321' + 4'3'2'1)0
   print_int3(w, 3,2,0); // 5
// ~  (51' + 4'3'2'1)0
   print_int3(w, 4,3,3); // 6
// ~  (51' + 62'1)0
   print_int3(w, 2,1,1); // 7
// ~  (51' + 67)0
   print_int3(w, 5,1,2); // 8
// ~  (8 + 67)0
   print_int3(w, 6,7,0); // 9
// ~  (8 + 9)0
   print_int3(w, 8,9,7); // 10
// ~  10x0
   print_int3(w, 10,0,4); // 11
*/


   print_int(w, 0xfff7f7f7);
   print_int(w, 5);
//The reduced boolean expression 0x80808 in SOP form: b'c'de + a'c'de
   print_int(w, 9);
// ~  3'2'10 + 4'2'10
   print_int3(w, 0,1,0);//5
// ~  3'2'5 + 4'2'5
   print_int3(w, 2,5,1);//6
// ~  3'6 + 4'6
   print_int3(w, 3,4,4);//7
// ~  76
   print_int3(w, 6,7,4);



// The reduced boolean expression  in SOP form: 10' + 2'1 + 20' + 21'
   print_int(w, 0x7c7c7c7c);
   print_int(w, 3);
//The reduced boolean expression 0x80808 in SOP form: b'c'de + a'c'de
   print_int(w, 8);
// 10' + 2'1 + 20' + 21'
   print_int3(w, 0,2,4);//3
// 13 + 20' + 21'
   print_int3(w, 0,1,4);//4
// 13 + 24
   print_int3(w, 1,3,0);//5
   print_int3(w, 2,4,0);//6
   print_int3(w, 5,6,7);

//The reduced boolean expression 0x2e2e2e2e in SOP form: 1'0 + 2'0 + 2'1
   print_int(w, 0x2e2e2e2e);
   print_int(w, 3);
   print_int(w, 7);
   print_int3(w, 1,2,4);
   print_int3(w, 3,0,0);
   print_int3(w, 1,2,2);
   print_int3(w, 4,5,7);
//The reduced boolean expression 0xe2e2e2e2 in SOP form: 1'0 + 20 + 21
   print_int(w, 0xe2e2e2e2);
   print_int(w, 3);
   print_int(w, 7);
   print_int3(w, 1,2,6);
   print_int3(w, 3,0,0);
   print_int3(w, 1,2,0);
   print_int3(w, 4,5,7);

// The reduced boolean expression 0x8800800 in SOP form: 32'10 + 43'210
   print_int(w, 0x8800800);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 1,0,0);//5 - 32'5 + 43'25
   print_int3(w, 3,2,2);//6 - 65 + 43'25
   print_int3(w, 4,3,2);//7 - 65 + 725
   print_int3(w, 2,5,0);//8 - 65 + 78
   print_int3(w, 6,5,0);
   print_int3(w, 8,7,0);
   print_int3(w, 9,10,7);
// The reduced boolean expression 0x8008800 in SOP form: 32'10 + 4'310
   print_int(w, 0x8008800);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 1,0,0);//5 - 32'5 + 4'35
   print_int3(w, 3,5,0);//6 - 62' + 4'6
   print_int3(w, 4,2,4);//7
   print_int3(w, 6,7,0);
// The reduced boolean expression 0xfffefefe in SOP form: 0 + 1 + 2 + 43
   print_int(w, 0xfffefefe);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 3,4,0);
   print_int3(w, 0,1,7);
   print_int3(w, 2,5,7);
   print_int3(w, 6,7,7);
// The reduced boolean expression 0xffefefef in SOP form: 0 + 1 + 2' + 43
   print_int(w, 0xffefefef);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 3,4,0);
   print_int3(w, 0,1,7);
   print_int3(w, 2,5,6);
   print_int3(w, 6,7,7);
// The reduced boolean expression 0xfefffeef in SOP form: 0 + 1 + 3'2' + 32 + 42 + 43'
   print_int(w, 0xfefffeef);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,1,7);
   print_int3(w, 3,2,12);
   print_int3(w, 2,3,5);
   print_int3(w, 4,7,0);
   print_int3(w, 5,6,7);
   print_int3(w, 9,8,7);
// The reduced boolean expression 0xeeebeeeb in SOP form: 0 + 21 + 3'2'1' + 31
   print_int(w, 0xeeebeeeb);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 2,3,7);
   print_int3(w, 5,1,0);
   print_int3(w, 0,6,7);
   print_int3(w, 2,3,3);
   print_int3(w, 8,1,2);
   print_int3(w, 9,7,7);
// The reduced boolean expression 0xeeeaeeea in SOP form: 0 + 21 + 31
   print_int(w, 0xeeeaeeea);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 2,3,7);
   print_int3(w, 4,1,0);
   print_int3(w, 0,5,7);

// The reduced boolean expression 0x9f9f9f9f in SOP form: 1'0' + 10 + 2'
   print_int(w, 0x9f9f9f9f);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 0,1,12);
   print_int3(w, 3,2,5);
#ifdef HIDE_BUG_SDI
// The reduced boolean expression 0x69966996 in SOP form: 3'2'1'0 + 3'2'10' + 3'21'0' + 3'210 + 32'1'0' + 32'10 + 321'0 + 3210'
   print_int(w, 0x69966996);
   print_int(w, 4);
   print_int(w, 18);
// 3'2'1'0 + 3'2'10' + 3'21'0' + 3'210 + 32'1'0' + 32'10 + 321'0 + 3210'
// (3'2' + 32)1'0 + 3'2'10' + 3'21'0' + 3'210 + 32'1'0' + 321'0 + 3210'
   print_int3(w, 2,3,12); // 4
// 41'0 + 3'2'10' + 3'21'0' + 3'210 + 32'1'0' + 321'0 + 3210'
// 41'0 + 3'2'10' + (3'2 + 32')1'0' + 3'210 + 321'0 + 3210'
   print_int3(w, 2,3,8); // 5
// 41'0 + 3'2'10' + 51'0' + 3'210 + 321'0 + 3210'
// 41'0 + 3'2'10' + 51'0' + 3'210 + 32(1'0 + 10')
   print_int3(w, 2,3,0); // 6
// 41'0 + 3'2'10' + 51'0' + 3'210 + 6(1'0 + 10')
   print_int3(w, 0,1,8); // 7
// 41'0 + 3'2'10' + 51'0' + 3'210 + 67
// 41'0 + 3'(2'10' + 210) + 51'0' + 67
// 41'0 + 3'1(2'0' + 20) + 51'0' + 67
   print_int3(w, 0,2,12); // 8
// 41'0 + 3'18 + 51'0' + 67
// 1'(40 + 50') + 3'18 + 67
   print_int3(w, 0,4,0); // 9
// 1'(9 + 50') + 3'18 + 67
   print_int3(w, 0,5,1); // A
// 1'(9 + A) + 3'18 + 67
   print_int3(w, 9,10,7); // B
// 1'B + 3'18 + 67
   print_int3(w, 1,8,0); // C
// 1'B + 3'C + 67
   print_int3(w, 6,7,0); // D
// 1'B + 3'C + D
   print_int3(w, 1,11,1); // E
// E + 3'C + D
   print_int3(w, 3,12,1); // F
// E + F + D
   print_int3(w, 13,14,7); // 16
   print_int3(w, 16,15,7); // 17
#endif
//   Info: the reduced boolean expression 0xff78ff78 in SOP form: [4 args][4 real args] -1--- --10- --1-0 --011
   print_int(w, 0xff78ff78);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 0,2,1);//4
   print_int3(w, 0,1,0);//5
   print_int3(w, 5,2,2);//6
   print_int3(w, 3,4,7);//7
   print_int3(w, 1,2,1);//8
   print_int3(w, 6,7,7);//9
   print_int3(w, 8,9,7);
// The reduced boolean expression 0x4f4f4f4f in SOP form: 10' + 2'
   print_int(w, 0x4f4f4f4f);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 1,0,2);
   print_int3(w, 3,2,5);
// The reduced boolean expression 0xcececece in SOP form: 1 + 2'0
   print_int(w, 0xcececece);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 2,0,1);
   print_int3(w, 3,1,7);
// The reduced boolean expression 0xf4f4f4f4 in SOP form: 10' + 2
   print_int(w, 0xf4f4f4f4);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 1,0,2);
   print_int3(w, 3,2,7);
// The reduced boolean expression 0xf2f2f2f2 in SOP form: 1'0 + 2
   print_int(w, 0xf2f2f2f2);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 1,0,1);
   print_int3(w, 3,2,7);
// TODO: cut-opt BUG:!!!
//   Info: the reduced boolean expression 0x44464446 in SOP form: [2 args][2 real args] ---10
/// ref/c++/qm-0.2/qm.py -o1,2,6,10,14
///     0001 XX10
   print_int(w, 0x44464446);
   print_int(w, 2+2);
   print_int(w, 3+2+4);
   print_int3(w, 0,1,1);//4
   print_int3(w, 0,1,2);//5
   print_int3(w, 2,3,3);//6
   print_int3(w, 5,6,0);
   print_int3(w, 4,7,7);
///////////////////////////////////////////////////////////////////
//   Info: the reduced boolean expression 0x20a020a0 in SOP form: [4 args][4 real args] -01-1 --101
   print_int(w, 0x20a020a0);
   print_int(w, 4);
   print_int(w, 8);
   print_int3(w, 0,2,0);//4
   print_int3(w, 4,3,2);//5
   print_int3(w, 4,1,2);//6
   print_int3(w, 5,6,7);
//   Info: the reduced boolean expression 0x4c004c0 in SOP form: [4 args][4 real args] -011- -1010
   print_int(w, 0x4c004c0);
   print_int(w, 4);
   print_int(w, 10);
   print_int3(w, 1,2,0);//4
   print_int3(w, 4,3,2);//5
   print_int3(w, 0,1,1);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 6,7,0);//8
   print_int3(w, 5,8,7);
//   Info: the reduced boolean expression 0x2a002a0 in SOP form: [4 args][4 real args] -01-1 -1001
   print_int(w, 0x2a002a0);
   print_int(w, 4);
   print_int(w, 10);
   print_int3(w, 2,3,2);//4
   print_int3(w, 4,0,0);//5
   print_int3(w, 0,1,2);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 6,7,0);//8
   print_int3(w, 5,8,7);
//   Info: the reduced boolean expression 0x88000800 in SOP form: [5 args][5 real args] -1011 11-11
   print_int(w, 0x88000800);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,1,0);//5
   print_int3(w, 2,3,1);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 3,4,0);//8
   print_int3(w, 5,8,0);//9
   print_int3(w, 7,9,7);
//   Info: the reduced boolean expression 0x66ca06a0 in SOP form: [5 args][5 real args] 001-1 -0111 -1001 -1010 100-1 1-001 10-11 1011- 1-110 11-01 11-10
//   Info: the reduced boolean expression 0xcaa66a00 in SOP form: [5 args][5 real args] -10-1 01-01 -1110 10-01 1-001 101-1 1-111 11-11 1111-

// Info: the reduced boolean expression 0x44000400 in SOP form: [5 args][5 real args] -1010 11-10
//   inverted form -- output invertion required-
//   Info: the reduced boolean expression 0xbbfffbff in SOP form: [4 args][3 real args] -0--- ---0- ----1
/*
   print_int(w, 0x44000400);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,1,0);//5
   print_int3(w, 2,3,1);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 3,4,0);//8
   print_int3(w, 5,8,0);//9
   print_int3(w, 7,9,7);
*/
//   Info: the reduced boolean expression 0x1e5a5a5a in SOP form: [5 args][5 real args] --0-1 0-1-0 -01-0 --100 1101-
   print_int(w, 0x1e5a5a5a);
   print_int(w, 5);
   print_int(w, 15);
   print_int3(w, 0,2,1);//5
   print_int3(w, 1,3,4);//6
   print_int3(w, 4,6,6);//7
   print_int3(w, 5,7,0);//8
   print_int3(w, 0,2,2);//9
   print_int3(w, 3,4,0);//10
   print_int3(w, 2,1,1);//11
   print_int3(w, 10,11,0);//12
   print_int3(w, 8,9,7);//13
   print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x8000880 in SOP form: [5 args][5 real args] -1011 00111
   print_int(w, 0x8000880);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 0,1,0);//5
   print_int3(w, 2,3,2);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 5,6,0);//8
   print_int3(w, 8,4,2);//9
   print_int3(w, 7,5,0);//10
   print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0xec88ec00 in SOP form: [5 args][5 real args] -1-1- -11-1 1--11
   print_int(w, 0xec88ec00);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 1,3,0);//5
   print_int3(w, 0,1,0);//6
   print_int3(w, 6,4,0);//7
   print_int3(w, 0,2,0);//8
   print_int3(w, 8,3,0);//9
   print_int3(w, 7,5,7);//10
   print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0x111aaaa in SOP form: [5 args][5 real args] 0---1 10-00 1-000
   print_int(w, 0x111aaaa);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 0,1,3);//5
   print_int3(w, 4,3,2);//6
   print_int3(w, 4,2,2);//7
   print_int3(w, 6,7,7);//8
   print_int3(w, 5,8,0);//9
   print_int3(w, 0,4,2);//10
   print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0xe000e0 in SOP form: [4 args][4 real args] -01-1 -011-
   print_int(w, 0xe000e0);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 3,2,1);//4
   print_int3(w, 0,1,7);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xe000e00 in SOP form: [4 args][4 real args] -10-1 -101-
   print_int(w, 0xe000e00);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 3,2,2);//4
   print_int3(w, 0,1,7);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xc080c08 in SOP form: [4 args][4 real args] --011 -101-
   print_int(w, 0xc080c08);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,2,2);//4
   print_int3(w, 0,3,7);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xe0e0e0e0 in SOP form: [3 args][3 real args] --1-1 --11-
   print_int(w, 0xe0e0e0e0);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 0,1,7);//3
   print_int3(w, 3,2,0);
//   Info: the reduced boolean expression 0x22202220 in SOP form: [4 args][4 real args] --101 -1-01
   print_int(w, 0x22202220);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,1,2);//4
   print_int3(w, 2,3,7);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0x44404440 in SOP form: [4 args][4 real args] --110 -1-10
   print_int(w, 0x44404440);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,1,1);//4
   print_int3(w, 2,3,7);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0x70707070 in SOP form: [3 args][3 real args] --10- --1-0
   print_int(w, 0x70707070);
   print_int(w, 3);
   print_int(w, 5);
   print_int3(w, 0,1,4);//3
   print_int3(w, 3,2,0);
//   Info: the reduced boolean expression 0x38383838 in SOP form: [3 args][3 real args] --10- --011
   print_int(w, 0x38383838);
   print_int(w, 3);
   print_int(w, 7);
   print_int3(w, 1,2,1);//3
   print_int3(w, 0,1,0);//4
   print_int3(w, 2,4,1);//5
   print_int3(w, 3,5,7);
//   Info: the reduced boolean expression 0x2288a888 in SOP form: [5 args][5 real args] 0--11 -0-11 011-1 11-01
   print_int(w, 0x2288a888);
   print_int(w, 5);
   print_int(w, 16);
   print_int3(w, 0,1,0);//5
   print_int3(w, 5,4,2);//6
   print_int3(w, 5,3,2);//7
   print_int3(w, 6,7,7);//8
   print_int3(w, 0,3,0);//9
   print_int3(w, 2,4,2);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 1,4,1);//12
   print_int3(w, 12,9,0);//13
   print_int3(w, 11,13,7);//14
   print_int3(w, 8,14,7);
//   Info: the reduced boolean expression 0x96c869eb in SOP form: [5 args][5 real args] 00--1 -0-11 -011- 0-000 0-011 0-101 0-110 1-111 11001 11010 11100
   print_int(w, 0x96c869eb);
   print_int(w, 5);
   print_int(w, 39);
   print_int3(w, 4,3,0);//5
   print_int3(w, 1,2,0);//6
   print_int3(w, 1,0,1);//7
   print_int3(w, 1,0,3);//8
   print_int3(w, 2,4,3);//9
   print_int3(w, 3,0,1);//10
   print_int3(w, 5,2,2);//11
   print_int3(w, 4,10,1);//12
   print_int3(w, 1,10,0);//13
   print_int3(w, 3,6,1);//14
   print_int3(w, 8,9,0);//15
   print_int3(w, 0,1,0);//16
   print_int3(w, 9,16,0);//17
   print_int3(w, 2,4,2);//18
   print_int3(w, 18,7,0);//19
   print_int3(w, 0,4,3);//20
   print_int3(w, 6,20,0);//21
   print_int3(w, 0,4,0);//22
   print_int3(w, 22,6,0);//23
   print_int3(w, 11,7,0);//24
   print_int3(w, 0,1,1);//25
   print_int3(w, 11,25,0);//26
   print_int3(w, 2,5,0);//27
   print_int3(w, 27,8,0);//28
   print_int3(w, 26,28,7);//29
   print_int3(w, 12,24,7);//30
   print_int3(w, 13,14,7);//31
   print_int3(w, 15,17,7);//32
   print_int3(w, 19,21,7);//33
   print_int3(w, 23,29,7);//34
   print_int3(w, 30,31,7);//35
   print_int3(w, 32,33,7);//36
   print_int3(w, 34,35,7);//37
   print_int3(w, 36,37,7);
//   Info: the reduced boolean expression 0x280028 in SOP form: [4 args][4 real args] -0011 -0101
   print_int(w, 0x280028);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,3,2);//4
   print_int3(w, 1,2,8);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xa0aa000c in SOP form: [5 args][5 real args] 10--1 1-1-1 0001-
   print_int(w, 0xa0aa000c);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 0,4,0);//5
   print_int3(w, 2,3,5);//6
   print_int3(w, 5,6,0);//7 +
   print_int3(w, 1,2,2);//8
   print_int3(w, 3,4,3);//9
   print_int3(w, 8,9,0);//10
   print_int3(w, 10,7,7);//11
//   Info: the reduced boolean expression 0xaaa8aaa8 in SOP form: [4 args][4 real args] ---11 --1-1 -1--1
   print_int(w, 0xaaa8aaa8);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,2,7);//4
   print_int3(w, 3,4,7);//5
   print_int3(w, 0,5,0);
//   Info: the reduced boolean expression 0xaa82aa82 in SOP form: [4 args][4 real args] -1--1 --001 --111
   print_int(w, 0xaa82aa82);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,2,12);//4
   print_int3(w, 4,3,7);//5
   print_int3(w, 0,5,0);
//   Info: the reduced boolean expression 0xaaaa88a0 in SOP form: [5 args][5 real args] 1---1 -01-1 -1-11
   print_int(w, 0xaaaa88a0);
   print_int(w, 5);
   print_int(w, 10);
   print_int3(w, 1,3,0);//5
   print_int3(w, 2,3,2);//6
   print_int3(w, 4,5,7);//7
   print_int3(w, 6,7,7);//8
   print_int3(w, 0,8,0);
//   Info: the reduced boolean expression 0x2a002a in SOP form: [4 args][4 real args] -00-1 -0-01
   print_int(w, 0x2a002a);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,2,4);//4
   print_int3(w, 0,3,2);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0x8a028a02 in SOP form: [4 args][4 real args] --001 -1-11
   print_int(w, 0x8a028a02);
   print_int(w, 4);
   print_int(w, 8);
   print_int3(w, 1,2,3);//4
   print_int3(w, 1,3,0);//5
   print_int3(w, 4,5,7);
   print_int3(w, 0,6,0);
//   Info: the reduced boolean expression 0xa8000 in SOP form: [5 args][5 real args] 100-1 01111
   print_int(w, 0xa8000);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 1,2,0);//5
   print_int3(w, 2,3,3);//6
   print_int3(w, 4,6,0);//7
   print_int3(w, 3,5,0);//8
   print_int3(w, 4,8,1);//9
   print_int3(w, 7,9,7);
   print_int3(w, 0,10,0);
//   Info: the reduced boolean expression 0xa28aa28a in SOP form: [4 args][4 real args] -00-1 --001 -0-11 --111 -1-01
   print_int(w, 0xa28aa28a);
   print_int(w, 4);
   print_int(w, 12);
   print_int3(w, 2,3,5);//4
   print_int3(w, 1,4,0);//5
   print_int3(w, 1,3,4);//6
   print_int3(w, 6,2,2);//7
   print_int3(w, 1,3,1);//8
   print_int3(w, 5,7,7);//9
   print_int3(w, 8,9,7);//10
   print_int3(w, 0,10,0);
//   Info: the reduced boolean expression 0xaa0ac in SOP form: [5 args][5 real args] 0-1-1 0001- 100-1
   print_int(w, 0xaa0ac);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 2,3,3);//5
   print_int3(w, 1,4,2);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 0,2,0);//8
   print_int3(w, 8,4,2);//9
   print_int3(w, 0,4,0);//10
   print_int3(w, 5,10,0);//11
   print_int3(w, 9,11,7);//12
   print_int3(w, 7,12,7);
//   Info: the reduced boolean expression 0x800a0000 in SOP form: [5 args][5 real args] 100-1 11111
   print_int(w, 0x800a0000);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,4,0);//5
   print_int3(w, 2,3,3);//6
   print_int3(w, 2,3,0);//7
   print_int3(w, 1,7,0);//8
   print_int3(w, 6,8,7);//9
   print_int3(w, 5,9,0);
//   Info: the reduced boolean expression 0x8a2a8a2a in SOP form: [4 args][4 real args] --0-1 -0-01 -1-11
   print_int(w, 0x8a2a8a2a);
   print_int(w, 4);
   print_int(w, 9);
   print_int3(w, 1,3,0);//4
   print_int3(w, 1,3,3);//5
   print_int3(w, 4,5,7);//6
   print_int3(w, 2,6,6);//7
   print_int3(w, 0,7,0);
//   Info: the reduced boolean expression 0x8a0000 in SOP form: [5 args][5 real args] 100-1 10-11
   print_int(w, 0x8a0000);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 3,4,1);//5
   print_int3(w, 0,5,0);//6
   print_int3(w, 1,2,5);//7
   print_int3(w, 6,7,0);
//   Info: the reduced boolean expression 0xa08a0000 in SOP form: [5 args][5 real args] 100-1 10-11 111-1
   print_int(w, 0xa08a0000);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 3,4,1);//5
   print_int3(w, 3,4,0);//6
   print_int3(w, 1,5,0);//7
   print_int3(w, 2,5,1);//8
   print_int3(w, 2,6,0);//9
   print_int3(w, 7,8,7);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 0,11,0);
//   Info: the reduced boolean expression 0x80aa0000 in SOP form: [5 args][5 real args] 10--1 1-111
   print_int(w, 0x80aa0000);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 1,2,0);//5
   print_int3(w, 0,4,0);//6
   print_int3(w, 3,5,6);//7
   print_int3(w, 6,7,0);
//   Info: the reduced boolean expression 0x8a008a00 in SOP form: [4 args][4 real args] -10-1 -1-11
   print_int(w, 0x8a008a00);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,3,0);//4
   print_int3(w, 1,2,5);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0x82008200 in SOP form: [4 args][4 real args] -1001 -1111
   print_int(w, 0x82008200);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,3,0);//4
   print_int3(w, 1,2,12);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xa0080 in SOP form: [5 args][5 real args] 100-1 00111
   print_int(w, 0xa0080);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 0,3,2);//5
   print_int3(w, 2,4,2);//6
   print_int3(w, 2,4,1);//7
   print_int3(w, 5,7,0);//8
   print_int3(w, 1,6,0);//9
   print_int3(w, 9,5,0);//10
   print_int3(w, 8,10,7);//
//   Info: the reduced boolean expression 0x8220822 in SOP form: [4 args][4 real args] -0-01 -1011
   print_int(w, 0x8220822);
   print_int(w, 4);
   print_int(w, 9);
   print_int3(w, 1,3,3);//4
   print_int3(w, 1,2,2);//5
   print_int3(w, 3,5,0);//6
   print_int3(w, 4,6,7);//7
   print_int3(w, 0,7,0);
//   Info: the reduced boolean expression 0xaa080 in SOP form: [5 args][5 real args] 0-111 011-1 100-1
   print_int(w, 0xaa080);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 2,4,2);//5
   print_int3(w, 2,3,3);//6
   print_int3(w, 4,6,0);//7
   print_int3(w, 1,5,0);//8
   print_int3(w, 5,3,0);//9
   print_int3(w, 7,8,7);//10
   print_int3(w, 10,9,7);//11
   print_int3(w, 0,11,0);
//   Info: the reduced boolean expression 0xaa88a0 in SOP form: [5 args][5 real args] -01-1 10--1 01-11
   print_int(w, 0xaa88a0);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 2,3,2);//5
   print_int3(w, 3,4,1);//6
   print_int3(w, 3,4,2);//7
   print_int3(w, 1,7,0);//8
   print_int3(w, 5,6,7);//9
   print_int3(w, 8,9,7);//10
   print_int3(w, 0,10,0);
/**/
//   Info: the reduced boolean expression 0xa8aaaa80 in SOP form: [5 args][5 real args] --111 01--1 -1-11 -11-1 10--1
   print_int(w, 0xa8aaaa80);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 3,4,8);//5
   print_int3(w, 1,2,0);//6
   print_int3(w, 1,3,0);//7
   print_int3(w, 2,3,0);//8
   print_int3(w, 5,6,7);//9
   print_int3(w, 7,8,7);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 0,11,0);
//   Info: the reduced boolean expression 0xa80aa080 in SOP form: [5 args][5 real args] -11-1 0-111 100-1 1-011
   print_int(w, 0xa80aa080);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 2,4,8);//5
   print_int3(w, 5,1,0);//6
   print_int3(w, 2,3,0);//7
   print_int3(w, 2,3,3);//8
   print_int3(w, 4,8,0);//9
   print_int3(w, 6,7,7);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 0,11,0);
//   Info: the reduced boolean expression 0x8aaaa8a0 in SOP form: [5 args][5 real args] 0-1-1 -01-1 -1-11 1-0-1
   print_int(w, 0x8aaaa8a0);
   print_int(w, 5);
   print_int(w, 11); 
   print_int3(w, 2,4,8);//5
   print_int3(w, 1,3,0);//6
   print_int3(w, 2,3,2);//7
   print_int3(w, 5,6,7);//8
   print_int3(w, 7,8,7);//9
   print_int3(w, 9,0,0);
//   Info: the reduced boolean expression 0x80aa08a0 in SOP form: [5 args][5 real args] -01-1 10--1 1-111 01011
   print_int(w, 0x80aa08a0);
   print_int(w, 5);
   print_int(w, 16);
   print_int3(w, 2,3,2);//5
   print_int3(w, 3,4,1);//6
   print_int3(w, 1,2,0);//7
   print_int3(w, 4,7,0);//8
   print_int3(w, 1,2,2);//9
   print_int3(w, 3,4,2);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 5,6,7);
   print_int3(w, 8,11,7);
   print_int3(w, 12,13,7);
   print_int3(w, 0,14,0);
//   Info: the reduced boolean expression 0xa88aaaa0 in SOP form: [5 args][5 real args] 0-1-1 --111 01--1 -1-11 -11-1 100-1
   print_int(w, 0xa88aaaa0);
   print_int(w, 5);
   print_int(w, 18);
   print_int3(w, 2,4,2);//5
   print_int3(w, 1,2,0);//6
   print_int3(w, 3,4,2);//7
   print_int3(w, 1,3,0);//8
   print_int3(w, 2,3,0);//9
   print_int3(w, 2,3,3);//10
   print_int3(w, 4,10,0);//11
   print_int3(w, 5,6,7);//12
   print_int3(w, 7,8,7);//13
   print_int3(w, 9,11,7);//14
   print_int3(w, 12,13,7);//15
   print_int3(w, 14,15,7);//16
   print_int3(w, 0,16,0);//17
/**/
//   Info: the reduced boolean expression 0xa8a0a8a0 in SOP form: [4 args][4 real args] --1-1 -1-11
   print_int(w, 0xa8a0a8a0);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,3,0);//4
   print_int3(w, 4,2,7);//5
   print_int3(w, 5,0,0);
//   Info: the reduced boolean expression 0x80828082 in SOP form: [4 args][4 real args] --111 -0001
   print_int(w, 0x80828082);
   print_int(w, 4);
   print_int(w, 9);
   print_int3(w, 1,3,3);//4
   print_int3(w, 4,2,2);//5
   print_int3(w, 1,2,0);//6
   print_int3(w, 5,6,7);//7
   print_int3(w, 7,0,0);
//   Info: the reduced boolean expression 0x800080 in SOP form: [4 args][4 real args] -0111
   print_int(w, 0x800080);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,1,0);//4
   print_int3(w, 2,3,2);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xaa80aa80 in SOP form: [4 args][4 real args] -1--1 --111
   print_int(w, 0xaa80aa80);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,2,0);//4
   print_int3(w, 4,3,7);//5
   print_int3(w, 0,5,0);
//   Info: the reduced boolean expression 0x28a028a in SOP form: [4 args][4 real args] --001 -0-11
   print_int(w, 0x28a028a);
   print_int(w, 4);
   print_int(w, 8);
   print_int3(w, 1,2,3);//4
   print_int3(w, 1,3,2);//5
   print_int3(w, 4,5,7);//6
   print_int3(w, 0,6,0);
// refactor cut [c8aaaa00]: 27 cells [5 args][5 real args] 01--1 -1-11 10--1 1111-
   print_int(w, 0xc8aaaa00);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 1,3,0);//5
   print_int3(w, 3,4,8);//6
   print_int3(w, 0,6,0);//7
   print_int3(w, 4,5,0);//8
   print_int3(w, 2,8,0);//9
   print_int3(w, 0,5,0);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 7,11,7);
//   Info: the reduced boolean expression 0x55575557 in SOP form: [4 args][4 real args] ----0 -000-
   print_int(w, 0x55575557);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 1,2,3);//4
   print_int3(w, 4,3,2);//5
   print_int3(w, 0,5,6);
//   Info: the reduced boolean expression 0x4c804c8 in SOP form: [4 args][4 real args] -0-11 -011- -1010
   print_int(w, 0x4c804c8);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 1,3,2);//4
   print_int3(w, 2,0,7);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 0,1,1);//8
   print_int3(w, 7,8,0);//9
   print_int3(w, 6,9,7);
//   Info: the reduced boolean expression 0xcec60000 in SOP form: [5 args][5 real args] 1--10 1-11- 11-1- 1-001
   print_int(w, 0xcec60000);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 0,1,1);//5
   print_int3(w, 1,2,0);//6
   print_int3(w, 1,3,0);//7
   print_int3(w, 1,2,3);//8
   print_int3(w, 0,8,0);//9
   print_int3(w, 5,6,7);//10
   print_int3(w, 7,9,7);//11
   print_int3(w, 10,11,7);//12
   print_int3(w, 4,12,0);
//   Info: the reduced boolean expression 0x54fcd888 in SOP form: [5 args][5 real args] 0--11 -0-11 -11-0 1--10 101--
   print_int(w, 0x54fcd888);
   print_int(w, 5);
   print_int(w, 17);
   print_int3(w, 0,1,0);//5
   print_int3(w, 3,4,4);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 2,3,0);//8
   print_int3(w, 0,8,1);//9
   print_int3(w, 1,4,0);//10
   print_int3(w, 10,0,2);//11
   print_int3(w, 2,4,0);//12
   print_int3(w, 12,3,2);//13
   print_int3(w, 7,9,7);//14
   print_int3(w, 11,13,7);//15
   print_int3(w, 14,15,7);
//   Info: the reduced boolean expression 0xeeeeeeef in SOP form: [5 args][5 real args] ----1 ---1- 000--
   print_int(w, 0xeeeeeeef);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 0,1,7);//5
   print_int3(w, 2,3,3);//6
   print_int3(w, 4,6,1);//7
   print_int3(w, 5,7,7);
//   Info: the reduced boolean expression 0xa8898989 in SOP form: [5 args][5 real args] ---11 0-000 -0000 111-1
   print_int(w, 0xa8898989);
   print_int(w, 5);
   print_int(w, 15);
   print_int3(w, 0,1,0);//5
   print_int3(w, 0,1,3);//6
   print_int3(w, 3,4,0);//7
   print_int3(w, 0,2,0);//8
   print_int3(w, 7,8,0);//9
   print_int3(w, 5,9,7);//10
   print_int3(w, 2,6,1);//11
   print_int3(w, 3,4,4);//12
   print_int3(w, 11,12,0);//13
   print_int3(w, 10,13,7);
//   Info: the reduced boolean expression 0x62222222 in SOP form: [5 args][5 real args] ---01 11110
   print_int(w, 0x62222222);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,1,2);//5
   print_int3(w, 0,1,1);//6
   print_int3(w, 3,4,0);//7
   print_int3(w, 7,2,0);//8
   print_int3(w, 8,6,0);//9
   print_int3(w, 9,5,7);
//   Info: the reduced boolean expression 0xa480a480 in SOP form: [4 args][4 real args] --111 -11-1 -1010
   print_int(w, 0xa480a480);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 0,2,0);//4
   print_int3(w, 1,3,7);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 0,1,1);//8
   print_int3(w, 7,8,0);//9
   print_int3(w, 6,9,7);
//   Info: the reduced boolean expression 0xb5c0b5c0 in SOP form: [4 args][4 real args] -011- --111 -10-0 -1-00 -110-
/*
-011-
--111
-10-0
-1-00
-110-
   print_int(w, 0xb5c0b5c0);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 1,3,2);//4
   print_int3(w, 2,0,7);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 0,1,1);//8
   print_int3(w, 7,8,0);//9
   print_int3(w, 6,9,7);
//   Info: the reduced boolean expression 0xbdc0bdc0 in SOP form: [4 args][4 real args] -011- --111 -10-0 -1-00 -101- -110-
-011-
--111
-10-0
-1-00
-101-
-110-
   print_int(w, 0xbdc0bdc0);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 1,3,2);//4
   print_int3(w, 2,0,7);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 2,3,1);//7
   print_int3(w, 0,1,1);//8
   print_int3(w, 7,8,0);//9
   print_int3(w, 6,9,7);
*/
//   Info: the reduced boolean expression 0x2080208 in SOP form: [4 args][4 real args] -0011 -1001
   print_int(w, 0x2080208);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,2,2);//4
   print_int3(w, 1,3,8);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0x2800280 in SOP form: [4 args][4 real args] -0111 -1001
   print_int(w, 0x2800280);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 0,1,0);//4
   print_int3(w, 0,1,2);//5
   print_int3(w, 2,3,1);//6
   print_int3(w, 2,3,2);//7
   print_int3(w, 5,6,0);//8
   print_int3(w, 4,7,0);//9
   print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0x2800a8a0 in SOP form: [5 args][5 real args] 0-1-1 -1011 -1101
   print_int(w, 0x2800a8a0);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 2,4,2);//5
   print_int3(w, 1,2,8);//6
   print_int3(w, 3,0,0);//7
   print_int3(w, 7,6,0);//8
   print_int3(w, 0,5,0);//9
   print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0xa8002200 in SOP form: [5 args][5 real args] 01-01 -1101 11-11
   print_int(w, 0xa8002200); // TODO: here we can factor relative to '0', but also may use 0 as early as possible... need to extend with delay selectors... i.e. set most critical signal
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 1,3,1);//5
   print_int3(w, 0,1,0);//6
   print_int3(w, 3,4,0);//7
   print_int3(w, 7,6,0);//8
   print_int3(w, 5,0,0);//9
   print_int3(w, 2,4,5);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 8,11,7);
//   Info: the reduced boolean expression 0x2a00820 in SOP form: [5 args][5 real args] -0101 101-1 01011 11001
   print_int(w, 0x2a00820);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 2,3,2);//5
   print_int3(w, 2,3,1);//6
   print_int3(w, 0,6,0);//7
   print_int3(w, 1,4,8);//8
   print_int3(w, 8,7,0);//9
   print_int3(w, 0,5,0);//10
   print_int3(w, 1,4,6);//11
   print_int3(w, 10,11,0);//12
   print_int3(w, 9,12,7);
//   Info: the reduced boolean expression 0x2800a200 in SOP form: [5 args][5 real args] 01-01 011-1 -1101 11011
   print_int(w, 0x2800a200);
   print_int(w, 5);
   print_int(w, 16);
   print_int3(w, 0,3,0);//5
   print_int3(w, 4,5,1);//6
   print_int3(w, 1,2,1);//7
   print_int3(w, 5,7,0);//8
   print_int3(w, 1,2,2);//9
   print_int3(w, 4,5,0);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 1,2,6);//12
   print_int3(w, 6,12,0);//13
   print_int3(w, 8,11,7);
   print_int3(w, 14,13,7);
//   Info: the reduced boolean expression 0x20a820a8 in SOP form: [4 args][4 real args] -0-11 --101
   print_int(w, 0x20a820a8);
   print_int(w, 4);
   print_int(w, 8);
   print_int3(w, 1,3,2);//4
   print_int3(w, 1,2,1);//5
   print_int3(w, 4,5,7);//6
   print_int3(w, 6,0,0);
//   Info: the reduced boolean expression 0xa002a002 in SOP form: [4 args][4 real args] -11-1 -0001
   print_int(w, 0xa002a002);
   print_int(w, 4);
   print_int(w, 9);
   print_int3(w, 2,3,0);//4
   print_int3(w, 1,2,3);//5
   print_int3(w, 3,5,1);//6
   print_int3(w, 4,6,7);//7
   print_int3(w, 7,0,0);
//   Info: the reduced boolean expression 0x20802080 in SOP form: [4 args][4 real args] -0111 -1101
   print_int(w, 0x20802080);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 2,0,0);//4
   print_int3(w, 1,3,8);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0x8200820 in SOP form: [4 args][4 real args] -0101 -1011
   print_int(w, 0x8200820);
   print_int(w, 4);
   print_int(w, 10);
   print_int3(w, 2,3,2);//4
   print_int3(w, 4,1,2);//5
   print_int3(w, 2,3,1);//6
   print_int3(w, 6,1,0);//7
   print_int3(w, 5,7,7);//8
   print_int3(w, 8,0,0);
//   Info: the reduced boolean expression 0x8280828 in SOP form: [4 args][4 real args] --011 -0101
   print_int(w, 0x8280828);
   print_int(w, 4);
   print_int(w, 9);
   print_int3(w, 1,2,2);//4
   print_int3(w, 1,2,1);//5
   print_int3(w, 5,3,2);//6
   print_int3(w, 6,4,7);//7
   print_int3(w, 7,0,0);
//   Info: the reduced boolean expression 0xa080a080 in SOP form: [4 args][4 real args] --111 -11-1
   print_int(w, 0xa080a080);
   print_int(w, 4);
   print_int(w, 7);
   print_int3(w, 0,2,0);//4
   print_int3(w, 1,3,7);//5
   print_int3(w, 4,5,0);
//   Info: the reduced boolean expression 0xa820a820 in SOP form: [4 args][4 real args] --101 -1-11
   print_int(w, 0xa820a820);
   print_int(w, 4);
   print_int(w, 8);
   print_int3(w, 1,3,0);//4
   print_int3(w, 1,2,1);//5
   print_int3(w, 4,5,7);//6
   print_int3(w, 6,0,0);
//   Info: the reduced boolean expression 0x20822082 in SOP form: [4 args][4 real args] -0001 -0111 -1101
   print_int(w, 0x20822082);
   print_int(w, 4);
   print_int(w, 11);
   print_int3(w, 0,2,0);//4
   print_int3(w, 1,3,8);//5
   print_int3(w, 0,1,2);//6
   print_int3(w, 2,3,3);//7
   print_int3(w, 6,7,0);//8
   print_int3(w, 4,5,0);//9
   print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0xa008a0 in SOP form: [5 args][5 real args] -01-1 01011
   print_int(w, 0xa008a0);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 2,3,2);//5
   print_int3(w, 3,4,2);//6
   print_int3(w, 1,2,2);//7
   print_int3(w, 6,7,0);//8
   print_int3(w, 5,8,7);//9
   print_int3(w, 9,0,0);
//   Info: the reduced boolean expression 0xa800a000 in SOP form: [5 args][5 real args] -11-1 11-11
   print_int(w, 0xa800a000);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 0,3,0);//5
   print_int3(w, 1,4,0);//6
   print_int3(w, 6,2,7);//7
   print_int3(w, 7,5,0);
//   Info: the reduced boolean expression 0xa8aaa8a0 in SOP form: [5 args][5 real args] --1-1 -1-11 10--1
   print_int(w, 0xa8aaa8a0);
   print_int(w, 5);
   print_int(w, 10);
   print_int3(w, 3,4,1);//5
   print_int3(w, 1,3,0);//6
   print_int3(w, 6,5,7);//7
   print_int3(w, 7,2,7);//8
   print_int3(w, 8,0,0);
//   Info: the reduced boolean expression 0xa8a02800 in SOP form: [5 args][5 real args] 1-1-1 -1011 -1101
   print_int(w, 0xa8a02800);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 3,0,0);//5
   print_int3(w, 1,2,8);//6
   print_int3(w, 6,5,0);//7
   print_int3(w, 4,2,0);//8
   print_int3(w, 8,0,0);//9
   print_int3(w, 9,7,7);
//   Info: the reduced boolean expression 0x2880288 in SOP form: [4 args][4 real args] -0-11 -1001
   print_int(w, 0x2880288);
   print_int(w, 4);
   print_int(w, 9);
   print_int3(w, 1,3,2);//4
   print_int3(w, 1,2,3);//5
   print_int3(w, 5,3,0);//6
   print_int3(w, 4,6,7);//7
   print_int3(w, 7,0,0);
//   Info: the reduced boolean expression 0x820a8a0 in SOP form: [5 args][5 real args] 0-1-1 -0101 -1011
   print_int(w, 0x820a8a0);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 3,1,3);//5
   print_int3(w, 4,5,6);//6
   print_int3(w, 1,2,2);//7
   print_int3(w, 3,7,0);//8
   print_int3(w, 2,6,0);//9
   print_int3(w, 8,9,7);//10
   print_int3(w, 10,0,0);
//   Info: the reduced boolean expression 0x88888889 in SOP form: [5 args][5 real args] ---11 00000
   print_int(w, 0x88888889);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,1,0);//5
   print_int3(w, 0,1,3);//6
   print_int3(w, 2,3,3);//7
   print_int3(w, 4,7,1);//8
   print_int3(w, 6,8,0);//9
   print_int3(w, 5,9,7);
//   Info: the reduced boolean expression 0xd7575777 in SOP form: [5 args][5 real args] ----0 --00- 00-0- 1111-
   print_int(w, 0xd7575777);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 3,4,3);//5
   print_int3(w, 5,2,5);//6
   print_int3(w, 1,6,1);//7
   print_int3(w, 7,0,5);//8
   print_int3(w, 1,2,0);//9
   print_int3(w, 3,4,0);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 8,11,7);
//   Info: the reduced boolean expression 0x2a2828a8 in SOP form: [5 args][5 real args] --011 --101 00-11 110-1
   print_int(w, 0x2a2828a8);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 3,4,3);//5
   print_int3(w, 3,4,0);//6
   print_int3(w, 1,2,8);//7
   print_int3(w, 7,0,0);//8
   print_int3(w, 1,5,0);//9
   print_int3(w, 2,6,1);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 0,11,0);//12
   print_int3(w, 8,12,7);
//   Info: the reduced boolean expression 0x42626222 in SOP form: [5 args][5 real args] 0--01 -0-01 --001 -1110 1-110
   print_int(w, 0x42626222);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 1,2,0);//5
   print_int3(w, 3,4,7);//6
   print_int3(w, 5,0,2);//7
   print_int3(w, 7,6,0);//8
   print_int3(w, 4,3,4);//9
   print_int3(w, 2,9,6);//10
   print_int3(w, 0,1,2);//11
   print_int3(w, 10,11,0);//12
   print_int3(w, 8,12,7);
//   Info: the reduced boolean expression 0x57575777 in SOP form: [5 args][5 real args] ----0 --00- 00-0-
   print_int(w, 0x57575777);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 3,4,3);//5
   print_int3(w, 2,5,6);//6
   print_int3(w, 6,1,2);//7
   print_int3(w, 7,0,5);
//   Info: the reduced boolean expression 0xa9b9b9b9 in SOP form: [5 args][5 real args] ---11 --1-1 0--00 -0-00 --000
   print_int(w, 0xa9b9b9b9);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 0,1,3);//5
   print_int3(w, 2,3,4);//6
   print_int3(w, 4,6,6);//7
   print_int3(w, 7,5,0);//8
   print_int3(w, 1,2,7);//9
   print_int3(w, 0,9,0);//10
   print_int3(w, 8,10,7);
//   Info: the reduced boolean expression 0x54464446 in SOP form: [5 args][5 real args] ---10 -0001 111-0
   print_int(w, 0x54464446);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 0,1,2);//5
   print_int3(w, 2,3,3);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 4,3,0);//8
   print_int3(w, 2,8,0);//9
   print_int3(w, 1,9,7);//10
   print_int3(w, 0,10,1);//11
   print_int3(w, 7,11,7);
//   Info: the reduced boolean expression 0xaaababab in SOP form: [5 args][5 real args] ----1 0-00- -000-
   print_int(w, 0xaaababab);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 1,2,3);//5
   print_int3(w, 3,4,4);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 7,0,7);
//   Info: the reduced boolean expression 0x999d9d9d in SOP form: [5 args][5 real args] ---00 ---11 0-0-0 -00-0
   print_int(w, 0x999d9d9d);
   print_int(w, 5);
   print_int(w, 10);
   print_int3(w, 0,1,12);//5
   print_int3(w, 0,2,3);//6
   print_int3(w, 3,4,4);//7
   print_int3(w, 7,6,0);//8
   print_int3(w, 5,8,7);
//   Info: the reduced boolean expression 0xb9bdbd9d in SOP form: [5 args][5 real args] ---00 ---11 0-0-0 -00-0 -110- 1-10-
   print_int(w, 0xb9bdbd9d);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 0,1,12);//5
   print_int3(w, 0,2,3);//6
   print_int3(w, 3,4,4);//7
   print_int3(w, 7,6,0);//8
   print_int3(w, 1,2,1);//9
   print_int3(w, 3,4,7);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 5,8,7);//12
   print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0xbbb9b9bd in SOP form: [5 args][5 real args] ---00 ---11 --10- 11-0- 000-0
   print_int(w, 0xbbb9b9bd);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 0,1,12);//5
   print_int3(w, 3,4,0);//6
   print_int3(w, 2,6,7);//7
   print_int3(w, 7,1,2);//8
   print_int3(w, 0,2,3);//9
   print_int3(w, 3,4,3);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 5,8,7);//12
   print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x46424262 in SOP form: [5 args][5 real args] --001 --110 00-01 11-10
   print_int(w, 0x46424262);
   print_int(w, 5);
   print_int(w, 14); // Q: calculate area w.r.t. XOR ?
   print_int3(w, 0,1,1);//5
   print_int3(w, 0,1,2);//6
   print_int3(w, 3,4,3);//7
   print_int3(w, 3,4,0);//8
   print_int3(w, 2,8,7);//9
   print_int3(w, 5,9,0);//10
   print_int3(w, 2,7,6);//11
   print_int3(w, 6,11,0);//12
   print_int3(w, 10,12,7);
//   Info: the reduced boolean expression 0x9d9d9dd5 in SOP form: [5 args][5 real args] --0-0 ---00 00--0 --111 -101- 1-01-
   print_int(w, 0x9d9d9dd5);
   print_int(w, 5);
   print_int(w, 16);
   print_int3(w, 3,4,3);//5
   print_int3(w, 1,2,4);//6
   print_int3(w, 5,6,7);//7
   print_int3(w, 0,7,1);//8
   print_int3(w, 1,2,2);//9
   print_int3(w, 3,4,7);//10
   print_int3(w, 9,10,0);//11
   print_int3(w, 0,1,0);//12
   print_int3(w, 2,12,0);//13
   print_int3(w, 13,11,7);//14
   print_int3(w, 14,8,7);
//   Info: the reduced boolean expression 0x222a2a28 in SOP form: [5 args][5 real args] --101 -1-01 1--01 0-011 -0011
   print_int(w, 0x222a2a28);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 0,1,2);//5
   print_int3(w, 2,3,7);//6
   print_int3(w, 6,4,7);//7
   print_int3(w, 5,7,0);//8
   print_int3(w, 0,1,0);//9
   print_int3(w, 9,2,2);//10
   print_int3(w, 3,4,4);//11
   print_int3(w, 10,11,0);//12
   print_int3(w, 8,12,7);
/*
//   Info: the reduced boolean expression 0xa7b7b779 in SOP form: [5 args][5 real args] 0--00 0-10- 01-0- -100- -10-0 -11-1 10-0- 1-0-0 1-1-1 001-0 00011
// Note: this one is way to non-optimial, as too many cases are possible... avoid such ones to be covered by others
   print_int(w, 0xa7b7b779);
   print_int(w, 5);
   print_int(w, 31);
   print_int3(w, 2,3,1);//5
   print_int3(w, 0,4,3);//6
   print_int3(w, 1,4,3);//7
   print_int3(w, 0,2,0);//8
   print_int3(w, 0,1,4);//9
   print_int3(w, 5,9,0);//10
   print_int3(w, 2,3,7);//11
   print_int3(w, 7,11,0);//12
   print_int3(w, 3,4,7);//13
   print_int3(w, 8,13,0);//14
   print_int3(w, 2,3,2);//15
   print_int3(w, 1,15,6);//16
   print_int3(w, 6,16,0);//17
   print_int3(w, 0,2,3);//18
   print_int3(w, 1,3,3);//19
   print_int3(w, 18,19,7);//20
   print_int3(w, 4,20,0);//21
   print_int3(w, 0,1,0);//22
   print_int3(w, 2,3,3);//23
   print_int3(w, 4,22,1);//24
   print_int3(w, 23,24,0);//25
   print_int3(w, 10,12,7);//26
   print_int3(w, 14,17,7);//27
   print_int3(w, 21,25,7);//28
   print_int3(w, 26,27,7);//29
   print_int3(w, 28,29,7);
*/
//   Info: the reduced boolean expression 0xaaaaaaab in SOP form: [5 args][5 real args] ----1 0000-
   print_int(w, 0xaaaaaaab);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 1,2,3);//5
   print_int3(w, 3,4,3);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 7,0,7);
//   Info: the reduced boolean expression 0xaf5f5588 in SOP form: [5 args][5 real args] 1-0-- 01--0 10--0 11--1 00-11
   print_int(w, 0xaf5f5588);
   print_int(w, 5);
   print_int(w, 16);
   print_int3(w, 2,4,1);//5
   print_int3(w, 3,4,8);//6
   print_int3(w, 0,6,1);//7
   print_int3(w, 0,1,0);//8
   print_int3(w, 3,4,3);//9
   print_int3(w, 8,9,0);//10
   print_int3(w, 3,4,0);//11
   print_int3(w, 0,11,0);//12
   print_int3(w, 5,7,7);//13
   print_int3(w, 10,12,7);//14
   print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xfcccc31c in SOP form: [5 args][5 real args] 1--1- -001- -111- 111-- 0100- 00100
   print_int(w, 0xfcccc31c);
   print_int(w, 5);
   print_int(w, 21);
   print_int3(w, 1,4,0);//5
   print_int3(w, 2,3,0);//6
   print_int3(w, 1,4,7);//7
   print_int3(w, 6,7,0);//8
   print_int3(w, 1,4,3);//9
   print_int3(w, 5,8,7);//10
   print_int3(w, 2,3,1);//11
   print_int3(w, 2,3,2);//12
   print_int3(w, 0,9,1);//13
   print_int3(w, 1,2,2);//14
   print_int3(w, 3,14,1);//15
   print_int3(w, 9,11,0);//16
   print_int3(w, 12,13,0);//17
   print_int3(w, 10,15,7);//18
   print_int3(w, 16,17,7);//19
   print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0xfaa5510 in SOP form: [5 args][5 real args] 01--0 -10-0 10--1 1-0-1 0-100
   print_int(w, 0xfaa5510);
   print_int(w, 5);
   print_int(w, 16);
   print_int3(w, 0,3,1);//5
   print_int3(w, 2,4,4);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 0,4,0);//8
   print_int3(w, 2,3,4);//9
   print_int3(w, 8,9,0);//10
   print_int3(w, 0,1,3);//11
   print_int3(w, 2,4,2);//12
   print_int3(w, 11,12,0);//13
   print_int3(w, 7,10,7);//14
   print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xaff8a00 in SOP form: [5 args][5 real args] 10--- -10-1 01-11
   print_int(w, 0xaff8a00);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 3,4,1);//5
   print_int3(w, 0,3,0);//6
   print_int3(w, 1,4,2);//7
   print_int3(w, 2,7,6);//8
   print_int3(w, 6,8,0);//9
   print_int3(w, 5,9,7);
//   Info: the reduced boolean expression 0xaf5f5580 in SOP form: [5 args][5 real args] 1-0-- 01--0 10--0 11--1 00111
   print_int(w, 0xaf5f5580);
   print_int(w, 5);
   print_int(w, 17);
   print_int3(w, 2,4,1);//5
   print_int3(w, 3,4,8);//6
   print_int3(w, 0,6,1);//7
   print_int3(w, 3,4,0);//8
   print_int3(w, 0,8,0);//9
   print_int3(w, 0,1,0);//10
   print_int3(w, 2,3,2);//11
   print_int3(w, 10,4,2);//12
   print_int3(w, 11,12,0);//13
   print_int3(w, 7,5,7);//14
   print_int3(w, 9,13,7);//15
   print_int3(w, 14,15,7);
//   Info: the reduced boolean expression 0xaf5f4500 in SOP form: [5 args][5 real args] 1-0-- -10-0 10--0 11--1 01-10
   print_int(w, 0xaf5f4500);
   print_int(w, 5);
   print_int(w, 19);
   print_int3(w, 2,4,1);//5
   print_int3(w, 0,2,3);//6
   print_int3(w, 3,6,0);//7
   print_int3(w, 3,4,1);//8
   print_int3(w, 0,8,1);//9
   print_int3(w, 0,3,0);//10
   print_int3(w, 10,4,0);//11
   print_int3(w, 0,1,1);//12
   print_int3(w, 3,4,2);//13
   print_int3(w, 12,13,0);//14
   print_int3(w, 5,7,7);//15
   print_int3(w, 9,11,7);//16
   print_int3(w, 15,14,7);//17
   print_int3(w, 16,17,7);
//    Info: the reduced boolean expression 0xfaa4500 in SOP form: [5 args][5 real args] -10-0 10--1 1-0-1 01-10
   print_int(w, 0xfaa4500);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 0,4,0);//5
   print_int3(w, 0,3,1);//6
   print_int3(w, 2,3,4);//7
   print_int3(w, 5,7,0);//8
   print_int3(w, 1,4,2);//9
   print_int3(w, 9,2,5);//10
   print_int3(w, 10,6,0);//11
   print_int3(w, 8,11,7);
//   Info: the reduced boolean expression 0xfaa0100 in SOP form: [5 args][5 real args] 10--1 110-- -1000
   print_int(w, 0xfaa0100);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 2,3,1);//5
   print_int3(w, 0,1,3);//6
   print_int3(w, 4,6,7);//7
   print_int3(w, 5,7,0);//8
   print_int3(w, 0,4,0);//9
   print_int3(w, 3,9,1);//10
   print_int3(w, 8,10,7);
//   Info: the reduced boolean expression 0xfcccc310 in SOP form: [5 args][5 real args] 1--1- -111- 111-- 0100- 00100
   print_int(w, 0xfcccc310);
   print_int(w, 5);
   print_int(w, 17);
   print_int3(w, 1,4,3);//5
   print_int3(w, 2,3,0);//6
   print_int3(w, 1,4,7);//7
   print_int3(w, 6,7,0);//8
   print_int3(w, 1,4,0);//9
   print_int3(w, 2,3,2);//10
   print_int3(w, 2,3,1);//11
   print_int3(w, 0,10,1);//12
   print_int3(w, 11,12,7);//13
   print_int3(w, 13,5,0);//14
   print_int3(w, 8,9,7);//15
   print_int3(w, 14,15,7);
/*
//   Info: the reduced boolean expression 0x28a828a8 in SOP form: [4 args][4 real args] -0-11 --011 --101
   print_int(w, 0x28a828a8);
   print_int(w, 4);
   print_int(w, 10);
   print_int3(w, 0,1,0);//4
   print_int3(w, 2,3,4);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 0,1,2);//7
   print_int3(w, 7,2,0);//8
   print_int3(w, 6,8,7);
*/
//   Info: the reduced boolean expression 0xa828a828 in SOP form: [4 args][4 real args] --011 --101 -1-11
   print_int(w, 0xa828a828);
   print_int(w, 4);
   print_int(w, 10);
   print_int3(w, 0,1,0);//4
   print_int3(w, 2,3,6);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 0,1,2);//7
   print_int3(w, 7,2,0);//8
   print_int3(w, 6,8,7);
//   Info: the reduced boolean expression 0xfffefff0 in SOP form: [5 args][5 real args] --1-- -1--- 1---1 1--1-
   print_int(w, 0xfffefff0);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 0,1,7);//5
   print_int3(w, 4,5,0);//6
   print_int3(w, 2,3,7);//7
   print_int3(w, 6,7,7);
//   Info: the reduced boolean expression 0xfffffff1 in SOP form: [5 args][5 real args] --1-- -1--- 1---- ---00
   print_int(w, 0xfffffff1);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 0,1,3);//5
   print_int3(w, 2,3,7);//6
   print_int3(w, 4,5,7);//7
   print_int3(w, 6,7,7);
//   Info: the reduced boolean expression 0x28a828a8 in SOP form: [4 args][4 real args] -0-11 --011 --101
   print_int(w, 0x28a828a8);
   print_int(w, 4);
/*
   print_int(w, 10);
   print_int3(w, 1,2,2);//4
   print_int3(w, 1,2,1);//5
   print_int3(w, 1,3,2);//6
   print_int3(w, 4,5,7);//7
   print_int3(w, 6,7,7);//8
   print_int3(w, 8,0,0);
*/
   print_int(w, 8);
   print_int3(w, 1,2,8);//4
   print_int3(w, 1,3,2);//5
   print_int3(w, 4,5,7);//6
   print_int3(w, 6,0,0);
//   Info: the reduced boolean expression 0xaa80aa8 in SOP form: [4 args][4 real args] -0-11 -01-1 -10-1
   print_int(w, 0xaa80aa8);
   print_int(w, 4);
   print_int(w, 8);
   print_int3(w, 2,3,8);//4
   print_int3(w, 1,3,2);//5
   print_int3(w, 4,5,7);//6
   print_int3(w, 6,0,0);
//   Info: the reduced boolean expression 0x60004000 in SOP form: [5 args][5 real args] -1110 11101
   print_int(w, 0x60004000);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 2,3,0);//5
   print_int3(w, 0,1,1);//6
   print_int3(w, 0,1,2);//7
   print_int3(w, 4,7,0);//8
   print_int3(w, 6,8,7);//9
   print_int3(w, 5,9,0);
//   Info: the reduced boolean expression 0x80a000 in SOP form: [5 args][5 real args] 011-1 10111
   print_int(w, 0x80a000);
   print_int(w, 5);
   print_int(w, 11);
   print_int3(w, 0,2,0);//5
   print_int3(w, 3,4,2);//6
   print_int3(w, 3,4,1);//7
   print_int3(w, 1,7,0);//8
   print_int3(w, 6,8,7);//9
   print_int3(w, 5,9,0);
//   Info: the reduced boolean expression 0xeffd5ddf in SOP form: [5 args][5 real args] 0---0 -0--0 --0-0 -0-1- --01- ---10 000-- 101-- 1-1-1 110--
   print_int(w, 0xeffd5ddf);
   print_int(w, 5);
   print_int(w, 21);
   print_int3(w, 2,3,8);//5
   print_int3(w, 5,4,0);//6
   print_int3(w, 2,3,4);//7
   print_int3(w, 1,7,0);//8
   print_int3(w, 1,2,5);//9
   print_int3(w, 3,4,4);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 0,11,1);//12
   print_int3(w, 0,2,0);//13
   print_int3(w, 13,4,0);//14
   print_int3(w, 2,3,3);//15
   print_int3(w, 4,15,1);//16
   print_int3(w, 6,14,7);//17
   print_int3(w, 8,16,7);//18
   print_int3(w, 12,17,7);//19
   print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0xff7dddff in SOP form: [5 args][5 real args] ----0 00--- 0--1- --01- 11--- -010-
   print_int(w, 0xff7dddff);
   print_int(w, 5);
   print_int(w, 15);
   print_int3(w, 3,4,3);//5
   print_int3(w, 3,4,0);//6
   print_int3(w, 2,4,4);//7
   print_int3(w, 1,7,0);//8
   print_int3(w, 1,2,1);//9
   print_int3(w, 9,3,2);//10
   print_int3(w, 0,10,6);//11
   print_int3(w, 5,8,7);//12
   print_int3(w, 11,6,7);//13
   print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x7e80ff00 in SOP form: [5 args][5 real args] 01--- -10-1 -101- -1-10 -110- 10111
   print_int(w, 0x7e80ff00);
   print_int(w, 5);
   print_int(w, 21);
   print_int3(w, 2,3,1);//5
   print_int3(w, 0,1,7);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 3,4,2);//8
   print_int3(w, 0,1,1);//9
   print_int3(w, 9,3,0);//10
   print_int3(w, 1,2,1);//11
   print_int3(w, 3,11,0);//12
   print_int3(w, 0,1,0);//13
   print_int3(w, 2,3,2);//14
   print_int3(w, 13,4,0);//15
   print_int3(w, 14,15,0);//16
   print_int3(w, 7,8,7);//17
   print_int3(w, 10,12,7);//18
   print_int3(w, 17,16,7);//19
   print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0xefed4ddf in SOP form: [5 args][5 real args] --0-0 -0-1- --01- ---10 000-- 00--0 1-1-1 110--
   print_int(w, 0xefed4ddf);
   print_int(w, 5);
   print_int(w, 20);
   print_int3(w, 3,4,3);//5
   print_int3(w, 0,2,4);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 0,2,4);//8
   print_int3(w, 8,3,5);//9
   print_int3(w, 1,9,0);//10
   print_int3(w, 0,2,3);//11
   print_int3(w, 0,2,0);//12
   print_int3(w, 4,12,0);//13
   print_int3(w, 2,3,1);//14
   print_int3(w, 14,4,0);//15
   print_int3(w, 15,13,7);//16
   print_int3(w, 7,10,7);//17
   print_int3(w, 17,11,7);//18
   print_int3(w, 16,18,7);
//   Info: the reduced boolean expression 0x10a0b020 in SOP form: [5 args][5 real args] 0-101 -1100 011-1 101-1
   print_int(w, 0x10a0b020);
   print_int(w, 5);
   print_int(w, 14);
   print_int3(w, 0,2,0);//5
   print_int3(w, 3,4,8);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 1,2,1);//8
   print_int3(w, 0,4,2);//9
   print_int3(w, 0,3,1);//10
   print_int3(w, 9,10,7);//11
   print_int3(w, 8,11,0);//12
   print_int3(w, 7,12,7);
//   Info: the reduced boolean expression 0xb300 in SOP form: [5 args][5 real args] 01-0- 011-1
   print_int(w, 0xb300);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 3,4,2);//5
   print_int3(w, 0,2,0);//6
   print_int3(w, 1,6,6);//7
   print_int3(w, 5,7,0);
//   Info: the reduced boolean expression 0x28000 in SOP form: [5 args][5 real args] 01111 10001
   print_int(w, 0x28000);
   print_int(w, 5);
   print_int(w, 13);
   print_int3(w, 1,2,0);//5
   print_int3(w, 3,4,2);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 1,2,3);//8
   print_int3(w, 3,4,1);//9
   print_int3(w, 8,9,0);//10
   print_int3(w, 7,10,7);//11
   print_int3(w, 0,11,0);
//   Info: the reduced boolean expression 0xa200 in SOP form: [5 args][5 real args] 01-01 011-1
   print_int(w, 0xa200);
   print_int(w, 5);
   print_int(w, 9);
   print_int3(w, 0,4,2);//5
   print_int3(w, 1,2,6);//6
   print_int3(w, 3,5,0);//7
   print_int3(w, 6,7,0);
//   Info: the reduced boolean expression 0xa22222 in SOP form: [5 args][5 real args] 0--01 -0-01 101-1
   print_int(w, 0xa22222);
   print_int(w, 5);
   print_int(w, 12);
   print_int3(w, 0,1,2);//5
   print_int3(w, 3,4,4);//6
   print_int3(w, 5,6,0);//7
   print_int3(w, 0,2,0);//8
   print_int3(w, 3,4,1);//9
   print_int3(w, 8,9,0);//10
   print_int3(w, 7,10,7);
//////////////////////////////////////
// Note: automatically generated cuts below this line
//       some of them produce non-optimal result
//////////////////////////////////////
//   Info: the reduced boolean expression 0x2c000000 in SOP form: [5 args][5 real args] 1101- 11101
      print_int(w, 0x2c000000);
      print_int(w, 5);
      print_int(w, 12);
      print_int3(w, 4,3,0);
      print_int3(w, 5,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,0,0);
      print_int3(w, 6,1,0);
      print_int3(w, 8,7,0);
      print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0xdbebffff in SOP form: [5 args][5 real args] 0---- --00- -0--1 --0-1 --11- -1-00
      print_int(w, 0xdbebffff);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 3,1,2);
      print_int3(w, 2,1,3);
      print_int3(w, 5,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,0,1);
      print_int3(w, 2,1,0);
      print_int3(w, 4,6,6);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xf2ebbfff in SOP form: [5 args][5 real args] 00--- 0-0-- 0--0- 0---1 -0--1 ---01 -000- -011- -110- 1-11-
      print_int(w, 0xf2ebbfff);
      print_int(w, 5);
      print_int(w, 27);
      print_int3(w, 2,1,0);
      print_int3(w, 4,3,3);
      print_int3(w, 4,2,3);
      print_int3(w, 3,2,3);
      print_int3(w, 2,1,2);
      print_int3(w, 8,1,2);
      print_int3(w, 4,1,3);
      print_int3(w, 4,0,1);
      print_int3(w, 3,0,1);
      print_int3(w, 1,0,1);
      print_int3(w, 4,5,0);
      print_int3(w, 3,5,1);
      print_int3(w, 3,9,0);
      print_int3(w, 6,7,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
      print_int3(w, 22,23,7);
      print_int3(w, 24,25,7);
//   Info: the reduced boolean expression 0xaaa00bfe in SOP form: [5 args][5 real args] 00--1 0-0-1 00-1- 001-- -01-1 -10-1 1-1-1 0100-
      print_int(w, 0xaaa00bfe);
      print_int(w, 5);
      print_int(w, 25);
      print_int3(w, 4,3,3);
      print_int3(w, 3,2,2);
      print_int3(w, 2,0,0);
      print_int3(w, 4,2,3);
      print_int3(w, 6,1,2);
      print_int3(w, 5,0,0);
      print_int3(w, 6,0,0);
      print_int3(w, 8,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 5,2,0);
      print_int3(w, 4,7,0);
      print_int3(w, 3,7,1);
      print_int3(w, 4,9,1);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
      print_int3(w, 22,23,7);
//   Info: the reduced boolean expression 0xfc7f003e in SOP form: [5 args][5 real args] -00-1 -001- -010- 100-- 10--0 1-01- 1--10 1-10- 11-1-
      print_int(w, 0xfc7f003e);
      print_int(w, 5);
      print_int(w, 26);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,2);
      print_int3(w, 4,3,2);
      print_int3(w, 6,2,2);
      print_int3(w, 6,0,2);
      print_int3(w, 8,0,2);
      print_int3(w, 5,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 6,3,0);
      print_int3(w, 4,5,0);
      print_int3(w, 4,7,0);
      print_int3(w, 3,7,1);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
//   Info: the reduced boolean expression 0xffff14ef in SOP form: [5 args][5 real args] 1---- -00-- -0--1 -0-1- --010 -1100
      print_int(w, 0xffff14ef);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 3,2,3);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 3,1,1);
      print_int3(w, 8,6,0);
      print_int3(w, 2,7,1);
      print_int3(w, 4,5,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0xb200 in SOP form: [5 args][5 real args] 01-01 0110- 011-1
      print_int(w, 0xb200);
      print_int(w, 5);
      print_int(w, 13);
      print_int3(w, 4,3,1);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,0);
      print_int3(w, 6,0,0);
      print_int3(w, 6,2,0);
      print_int3(w, 5,7,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xa20222 in SOP form: [5 args][5 real args] -0-01 0-001 101-1
      print_int(w, 0xa20222);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,3);
      print_int3(w, 5,1,2);
      print_int3(w, 6,1,2);
      print_int3(w, 8,0,0);
      print_int3(w, 4,2,0);
      print_int3(w, 10,5,0);
      print_int3(w, 7,9,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x822200 in SOP form: [5 args][5 real args] 01-01 10001 10111
      print_int(w, 0x822200);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,3,2);
      print_int3(w, 5,0,0);
      print_int3(w, 6,2,2);
      print_int3(w, 3,1,2);
      print_int3(w, 7,1,2);
      print_int3(w, 8,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 4,10,1);
      print_int3(w, 6,11,0);
      print_int3(w, 9,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xa21322 in SOP form: [5 args][5 real args] -0-01 0-001 01-00 101-1
      print_int(w, 0xa21322);
      print_int(w, 5);
      print_int(w, 17);
      print_int3(w, 4,1,3);
      print_int3(w, 3,0,1);
      print_int3(w, 5,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 4,2,0);
      print_int3(w, 11,6,0);
      print_int3(w, 5,9,0);
      print_int3(w, 8,10,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
//   Info: the reduced boolean expression 0xeffd4ddf in SOP form: [5 args][5 real args] -0--0 --0-0 -0-1- --01- ---10 000-- 101-- 1-1-1 110--
      print_int(w, 0xeffd4ddf);
      print_int(w, 5);
      print_int(w, 25);
      print_int3(w, 4,2,0);
      print_int3(w, 5,3,2);
      print_int3(w, 4,3,3);
      print_int3(w, 3,2,2);
      print_int3(w, 7,2,2);
      print_int3(w, 1,0,2);
      print_int3(w, 3,0,3);
      print_int3(w, 2,0,3);
      print_int3(w, 5,0,0);
      print_int3(w, 3,1,1);
      print_int3(w, 2,1,1);
      print_int3(w, 4,8,0);
      print_int3(w, 6,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
      print_int3(w, 22,23,7);
//   Info: the reduced boolean expression 0xa21222 in SOP form: [5 args][5 real args] -0-01 0-001 101-1 01100
      print_int(w, 0xa21222);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 4,1,3);
      print_int3(w, 3,0,1);
      print_int3(w, 5,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 4,2,0);
      print_int3(w, 5,3,0);
      print_int3(w, 11,6,0);
      print_int3(w, 12,9,0);
      print_int3(w, 8,10,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0xa20222 in SOP form: [5 args][5 real args] -0-01 0-001 101-1
      print_int(w, 0xa20222);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,3);
      print_int3(w, 5,1,2);
      print_int3(w, 6,1,2);
      print_int3(w, 8,0,0);
      print_int3(w, 4,2,0);
      print_int3(w, 10,5,0);
      print_int3(w, 7,9,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x11229100 in SOP form: [5 args][5 real args] -1-00 10-01 01111
      print_int(w, 0x11229100);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,3,2);
      print_int3(w, 3,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 7,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 11,9,0);
      print_int3(w, 4,12,1);
      print_int3(w, 8,10,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xff410300 in SOP form: [5 args][5 real args] 11--- -100- 1-000 1-110
      print_int(w, 0xff410300);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 2,1,3);
      print_int3(w, 4,0,2);
      print_int3(w, 2,1,0);
      print_int3(w, 4,3,0);
      print_int3(w, 3,5,0);
      print_int3(w, 6,5,0);
      print_int3(w, 6,7,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0xfc590018 in SOP form: [5 args][5 real args] 1-1-0 11-1- 111-- -0011 -0100 10-00
      print_int(w, 0xfc590018);
      print_int(w, 5);
      print_int(w, 22);
      print_int3(w, 3,1,3);
      print_int3(w, 2,0,2);
      print_int3(w, 4,3,0);
      print_int3(w, 3,2,3);
      print_int3(w, 4,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 7,1,0);
      print_int3(w, 7,2,0);
      print_int3(w, 9,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 5,6,0);
      print_int3(w, 8,10,0);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
//   Info: the reduced boolean expression 0x14281428 in SOP form: [4 args][4 real args] -0011 -0101 -1010 -1100
      print_int(w, 0x14281428);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,1);
      print_int3(w, 5,4,0);
      print_int3(w, 6,4,0);
      print_int3(w, 5,7,0);
      print_int3(w, 6,7,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x5c3a5c3a in SOP form: [4 args][4 real args] -00-1 -010- --100 -101- -1-10
      print_int(w, 0x5c3a5c3a);
      print_int(w, 4);
      print_int(w, 16);
      print_int3(w, 2,1,2);
      print_int3(w, 3,1,0);
      print_int3(w, 5,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 4,0,2);
      print_int3(w, 5,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 3,4,1);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x21842184 in SOP form: [4 args][4 real args] -0010 -0111 -1000 -1101
      print_int(w, 0x21842184);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,2);
      print_int3(w, 2,0,3);
      print_int3(w, 2,0,0);
      print_int3(w, 3,1,1);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x69966996 in SOP form: [4 args][4 real args] -0001 -0010 -0100 -0111 -1000 -1011 -1101 -1110
      print_int(w, 0x69966996);
      print_int(w, 4);
      print_int(w, 30-11);
   print_int3(w, 2,3,3);//4
   print_int3(w, 2,3,2);//5
   print_int3(w, 2,3,1);//6
   print_int3(w, 2,3,0);//7
   print_int3(w, 0,1,3);//8
   print_int3(w, 0,1,2);//9
   print_int3(w, 0,1,1);//10
   print_int3(w, 0,1,0);//11
   print_int3(w, 9,10,7);//12
   print_int3(w, 8,11,7);//13
   print_int3(w, 4,7,7);//14
   print_int3(w, 5,6,7);//15
   print_int3(w, 12,14,0);//16
   print_int3(w, 13,15,0);//17
   print_int3(w, 16,17,7);
/*
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 9,0,2);
      print_int3(w, 3,0,0);
      print_int3(w, 10,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 3,2,1);
      print_int3(w, 13,6,0);
      print_int3(w, 5,7,0);
      print_int3(w, 15,7,0);
      print_int3(w, 4,8,0);
      print_int3(w, 16,8,0);
      print_int3(w, 3,11,1);
      print_int3(w, 12,14,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
*/
//   Info: the reduced boolean expression 0x21842184 in SOP form: [4 args][4 real args] -0010 -0111 -1000 -1101
      print_int(w, 0x21842184);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,2);
      print_int3(w, 2,0,3);
      print_int3(w, 2,0,0);
      print_int3(w, 3,1,1);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x21842184 in SOP form: [4 args][4 real args] -0010 -0111 -1000 -1101
      print_int(w, 0x21842184);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,2);
      print_int3(w, 2,0,3);
      print_int3(w, 2,0,0);
      print_int3(w, 3,1,1);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0xde7b2184 in SOP form: [5 args][5 real args] 10-0- 1-0-1 1-1-0 11-1- 00010 00111 01000 01101
      print_int(w, 0xde7b2184);
      print_int(w, 5);
      print_int(w, 30-12);

   print_int3(w, 1,3,8);//5
   print_int3(w, 0,2,8);//6
   print_int3(w, 5,6,7);//7
   print_int3(w, 7,4,0);//8

   print_int3(w, 0,2,8);//9
   print_int3(w, 0,2,12);//10
   print_int3(w, 1,3,2);//11
   print_int3(w, 11,9,0);//12
   print_int3(w, 1,3,1);//13
      print_int3(w, 10,13,0);//14
      print_int3(w, 12,14,7);//15
      print_int3(w, 15,4,2);//16
      print_int3(w, 8,16,7);
/*
      print_int3(w, 4,3,3);
      print_int3(w, 3,1,2);
      print_int3(w, 2,0,3);
      print_int3(w, 2,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 4,6,1);
      print_int3(w, 4,3,2);
      print_int3(w, 4,2,2);
      print_int3(w, 11,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 12,0,0);
      print_int3(w, 3,1,0);
      print_int3(w, 9,7,0);
      print_int3(w, 10,7,0);
      print_int3(w, 9,8,0);
      print_int3(w, 10,8,0);
      print_int3(w, 4,14,0);
      print_int3(w, 4,16,0);
      print_int3(w, 13,15,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);*/
//   Info: the reduced boolean expression 0x21840000 in SOP form: [5 args][5 real args] 10010 10111 11000 11101
      print_int(w, 0x21840000);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 4,3,2);
      print_int3(w, 3,1,2);
      print_int3(w, 2,0,3);
      print_int3(w, 2,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 4,6,0);
      print_int3(w, 9,7,0);
      print_int3(w, 10,7,0);
      print_int3(w, 9,8,0);
      print_int3(w, 10,8,0);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0x35ac35ac in SOP form: [4 args][4 real args] -001- -01-1 --101 -10-0 -1-00
      print_int(w, 0x35ac35ac);
      print_int(w, 4);
      print_int(w, 16);
      print_int3(w, 3,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 4,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 7,1,0);
      print_int3(w, 3,5,1);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x48124812 in SOP form: [4 args][4 real args] -0001 -0100 -1011 -1110
      print_int(w, 0x48124812);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,3);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,1);
      print_int3(w, 3,1,0);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x48124812 in SOP form: [4 args][4 real args] -0001 -0100 -1011 -1110
      print_int(w, 0x48124812);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,3);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,1);
      print_int3(w, 3,1,0);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x48124812 in SOP form: [4 args][4 real args] -0001 -0100 -1011 -1110
      print_int(w, 0x48124812);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,3);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,1);
      print_int3(w, 3,1,0);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x9a6aa9a6 in SOP form: [5 args][5 real args] -0-01 0-1-1 -1-11 1-0-1 00010 01000 10110 11100
      print_int(w, 0x9a6aa9a6);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 4,2,3);
      print_int3(w, 3,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,2,0);
      print_int3(w, 3,7,1);
      print_int3(w, 4,2,2);
      print_int3(w, 3,1,3);
      print_int3(w, 1,0,0);
      print_int3(w, 2,0,0);
      print_int3(w, 11,0,0);
      print_int3(w, 12,0,0);
      print_int3(w, 5,8,0);
      print_int3(w, 9,8,0);
      print_int3(w, 5,10,0);
      print_int3(w, 9,10,0);
      print_int3(w, 3,13,0);
      print_int3(w, 4,14,1);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0x40801020 in SOP form: [5 args][5 real args] 00101 01100 10111 11110
      print_int(w, 0x40801020);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,8,0);
      print_int3(w, 9,6,0);
      print_int3(w, 10,6,0);
      print_int3(w, 9,7,0);
      print_int3(w, 10,7,0);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0xb478e1d2 in SOP form: [5 args][5 real args] -01-0 0-11- -11-1 1-10- 00001 01000 10011 11010
      print_int(w, 0xb478e1d2);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,3);
      print_int3(w, 5,0,2);
      print_int3(w, 6,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 7,8,0);
      print_int3(w, 10,8,0);
      print_int3(w, 7,9,0);
      print_int3(w, 10,9,0);
      print_int3(w, 4,11,0);
      print_int3(w, 3,12,1);
      print_int3(w, 3,13,0);
      print_int3(w, 4,14,1);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0x40801020 in SOP form: [5 args][5 real args] 00101 01100 10111 11110
      print_int(w, 0x40801020);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,8,0);
      print_int3(w, 9,6,0);
      print_int3(w, 10,6,0);
      print_int3(w, 9,7,0);
      print_int3(w, 10,7,0);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0xb478e1d2 in SOP form: [5 args][5 real args] -01-0 0-11- -11-1 1-10- 00001 01000 10011 11010
      print_int(w, 0xb478e1d2);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,3);
      print_int3(w, 5,0,2);
      print_int3(w, 6,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 7,8,0);
      print_int3(w, 10,8,0);
      print_int3(w, 7,9,0);
      print_int3(w, 10,9,0);
      print_int3(w, 4,11,0);
      print_int3(w, 3,12,1);
      print_int3(w, 3,13,0);
      print_int3(w, 4,14,1);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0x9a6aa9a6 in SOP form: [5 args][5 real args] -0-01 0-1-1 -1-11 1-0-1 00010 01000 10110 11100
      print_int(w, 0x9a6aa9a6);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 4,2,3);
      print_int3(w, 3,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,2,0);
      print_int3(w, 3,7,1);
      print_int3(w, 4,2,2);
      print_int3(w, 3,1,3);
      print_int3(w, 1,0,0);
      print_int3(w, 2,0,0);
      print_int3(w, 11,0,0);
      print_int3(w, 12,0,0);
      print_int3(w, 5,8,0);
      print_int3(w, 9,8,0);
      print_int3(w, 5,10,0);
      print_int3(w, 9,10,0);
      print_int3(w, 3,13,0);
      print_int3(w, 4,14,1);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0xb478e1d2 in SOP form: [5 args][5 real args] -01-0 0-11- -11-1 1-10- 00001 01000 10011 11010
      print_int(w, 0xb478e1d2);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,3);
      print_int3(w, 5,0,2);
      print_int3(w, 6,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 7,8,0);
      print_int3(w, 10,8,0);
      print_int3(w, 7,9,0);
      print_int3(w, 10,9,0);
      print_int3(w, 4,11,0);
      print_int3(w, 3,12,1);
      print_int3(w, 3,13,0);
      print_int3(w, 4,14,1);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0xb478e1d2 in SOP form: [5 args][5 real args] -01-0 0-11- -11-1 1-10- 00001 01000 10011 11010
      print_int(w, 0xb478e1d2);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,3);
      print_int3(w, 5,0,2);
      print_int3(w, 6,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 7,8,0);
      print_int3(w, 10,8,0);
      print_int3(w, 7,9,0);
      print_int3(w, 10,9,0);
      print_int3(w, 4,11,0);
      print_int3(w, 3,12,1);
      print_int3(w, 3,13,0);
      print_int3(w, 4,14,1);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0x48124812 in SOP form: [4 args][4 real args] -0001 -0100 -1011 -1110
      print_int(w, 0x48124812);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,3);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,1);
      print_int3(w, 3,1,0);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x48124812 in SOP form: [4 args][4 real args] -0001 -0100 -1011 -1110
      print_int(w, 0x48124812);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,1,3);
      print_int3(w, 2,0,2);
      print_int3(w, 2,0,1);
      print_int3(w, 3,1,0);
      print_int3(w, 4,5,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,6,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x40801020 in SOP form: [5 args][5 real args] 00101 01100 10111 11110
      print_int(w, 0x40801020);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,8,0);
      print_int3(w, 9,6,0);
      print_int3(w, 10,6,0);
      print_int3(w, 9,7,0);
      print_int3(w, 10,7,0);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0x40801020 in SOP form: [5 args][5 real args] 00101 01100 10111 11110
      print_int(w, 0x40801020);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,8,0);
      print_int3(w, 9,6,0);
      print_int3(w, 10,6,0);
      print_int3(w, 9,7,0);
      print_int3(w, 10,7,0);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0xfffd8000 in SOP form: [5 args][5 real args] 1---0 1--1- 1-1-- 11--- -1111
      print_int(w, 0xfffd8000);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,2,0);
      print_int3(w, 4,3,0);
      print_int3(w, 8,6,0);
      print_int3(w, 5,7,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xfffd8000 in SOP form: [5 args][5 real args] 1---0 1--1- 1-1-- 11--- -1111
      print_int(w, 0xfffd8000);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,2,0);
      print_int3(w, 4,3,0);
      print_int3(w, 8,6,0);
      print_int3(w, 5,7,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xf8f0e0f0 in SOP form: [5 args][5 real args] -01-- --1-1 --11- 1-1-- 11-11
      print_int(w, 0xf8f0e0f0);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 1,0,0);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 4,2,0);
      print_int3(w, 3,2,1);
      print_int3(w, 4,3,0);
      print_int3(w, 10,5,0);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x70f2f0f0 in SOP form: [5 args][5 real args] 0-1-- -01-- --10- --1-0 10-01
      print_int(w, 0x70f2f0f0);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,3,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 4,2,1);
      print_int3(w, 3,2,1);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x70f2f0f0 in SOP form: [5 args][5 real args] 0-1-- -01-- --10- --1-0 10-01
      print_int(w, 0x70f2f0f0);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,3,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 4,2,1);
      print_int3(w, 3,2,1);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x70f2f0e0 in SOP form: [5 args][5 real args] 0-1-1 0-11- --110 011-- -110- 101-- 10-01
      print_int(w, 0x70f2f0e0);
      print_int(w, 5);
      print_int(w, 23);
      print_int3(w, 4,2,1);
      print_int3(w, 4,3,2);
      print_int3(w, 2,1,2);
      print_int3(w, 6,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,0);
      print_int3(w, 8,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 6,2,0);
      print_int3(w, 5,3,0);
      print_int3(w, 3,7,0);
      print_int3(w, 2,9,0);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
//   Info: the reduced boolean expression 0xf8f0e0f0 in SOP form: [5 args][5 real args] -01-- --1-1 --11- 1-1-- 11-11
      print_int(w, 0xf8f0e0f0);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 1,0,0);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 4,2,0);
      print_int3(w, 3,2,1);
      print_int3(w, 4,3,0);
      print_int3(w, 10,5,0);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x70f2f0f0 in SOP form: [5 args][5 real args] 0-1-- -01-- --10- --1-0 10-01
      print_int(w, 0x70f2f0f0);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,3,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 4,2,1);
      print_int3(w, 3,2,1);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x70f2f0f0 in SOP form: [5 args][5 real args] 0-1-- -01-- --10- --1-0 10-01
      print_int(w, 0x70f2f0f0);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 4,3,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,2);
      print_int3(w, 7,0,0);
      print_int3(w, 4,2,1);
      print_int3(w, 3,2,1);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x70f2f0e0 in SOP form: [5 args][5 real args] 0-1-1 0-11- --110 011-- -110- 101-- 10-01
      print_int(w, 0x70f2f0e0);
      print_int(w, 5);
      print_int(w, 23);
      print_int3(w, 4,2,1);
      print_int3(w, 4,3,2);
      print_int3(w, 2,1,2);
      print_int3(w, 6,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,0);
      print_int3(w, 8,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 6,2,0);
      print_int3(w, 5,3,0);
      print_int3(w, 3,7,0);
      print_int3(w, 2,9,0);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
//   Info: the reduced boolean expression 0xab77ab77 in SOP form: [4 args][4 real args] -0-0- --00- -0--0 -1--1
      print_int(w, 0xab77ab77);
      print_int(w, 4);
      print_int(w, 11);
      print_int3(w, 3,1,3);
      print_int3(w, 2,1,3);
      print_int3(w, 3,0,3);
      print_int3(w, 3,0,0);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0xab77ab77 in SOP form: [4 args][4 real args] -0-0- --00- -0--0 -1--1
      print_int(w, 0xab77ab77);
      print_int(w, 4);
      print_int(w, 11);
      print_int3(w, 3,1,3);
      print_int3(w, 2,1,3);
      print_int3(w, 3,0,3);
      print_int3(w, 3,0,0);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0x5d9f5d9f in SOP form: [4 args][4 real args] -00-- ---00 --01- -1--0 -0-11
      print_int(w, 0x5d9f5d9f);
      print_int(w, 4);
      print_int(w, 14);
      print_int3(w, 3,2,3);
      print_int3(w, 3,0,2);
      print_int3(w, 1,0,3);
      print_int3(w, 1,0,0);
      print_int3(w, 2,1,1);
      print_int3(w, 3,7,1);
      print_int3(w, 4,5,7);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x1bb91bb9 in SOP form: [4 args][4 real args] ---00 -0-11 --011 -010- -100-
      print_int(w, 0x1bb91bb9);
      print_int(w, 4);
      print_int(w, 16);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,3);
      print_int3(w, 3,4,1);
      print_int3(w, 2,4,1);
      print_int3(w, 3,6,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x7fbf7fbf in SOP form: [4 args][4 real args] --0-- ---0- -0--1 -1--0
      print_int(w, 0x7fbf7fbf);
      print_int(w, 4);
      print_int(w, 9);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,4);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
//   Info: the reduced boolean expression 0x4c8e4c8e in SOP form: [4 args][4 real args] --01- -00-1 -0-11 -1-10
      print_int(w, 0x4c8e4c8e);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,2);
      print_int3(w, 1,0,2);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,1);
      print_int3(w, 3,6,0);
      print_int3(w, 5,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0x5d9e5d9e in SOP form: [4 args][4 real args] --01- -1--0 -00-1 -0-11 --100
      print_int(w, 0x5d9e5d9e);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,1);
      print_int3(w, 5,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x7fbe7fbe in SOP form: [4 args][4 real args] -0--1 --0-1 --01- --10- -1--0
      print_int(w, 0x7fbe7fbe);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,0,1);
      print_int3(w, 2,1,1);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0x15554555 in SOP form: [5 args][5 real args] -0--0 --0-0 0--10 1--00
      print_int(w, 0x15554555);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 4,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,2);
      print_int3(w, 3,0,3);
      print_int3(w, 2,0,3);
      print_int3(w, 4,6,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x1454541 in SOP form: [5 args][5 real args] --000 0-110 -0110 010-0 100-0
      print_int(w, 0x1454541);
      print_int(w, 5);
      print_int(w, 19);
      print_int3(w, 2,0,3);
      print_int3(w, 1,0,2);
      print_int3(w, 2,6,0);
      print_int3(w, 4,3,2);
      print_int3(w, 5,1,2);
      print_int3(w, 4,3,1);
      print_int3(w, 8,5,0);
      print_int3(w, 10,5,0);
      print_int3(w, 4,7,1);
      print_int3(w, 3,7,1);
      print_int3(w, 9,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
//   Info: the reduced boolean expression 0x44001000 in SOP form: [5 args][5 real args] 11-10 01100
      print_int(w, 0x44001000);
      print_int(w, 5);
      print_int(w, 12);
      print_int3(w, 3,0,2);
      print_int3(w, 2,1,2);
      print_int3(w, 4,1,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,5,1);
      print_int3(w, 9,6,0);
      print_int3(w, 8,10,7);
//   Info: the reduced boolean expression 0x54001000 in SOP form: [5 args][5 real args] -1100 11-10
      print_int(w, 0x54001000);
      print_int(w, 5);
      print_int(w, 11);
      print_int3(w, 3,0,2);
      print_int3(w, 2,1,2);
      print_int3(w, 4,1,0);
      print_int3(w, 7,5,0);
      print_int3(w, 5,6,0);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0x11514155 in SOP form: [5 args][5 real args] 00--0 --000 -01-0 1--00 0-110
      print_int(w, 0x11514155);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 2,0,2);
      print_int3(w, 1,0,3);
      print_int3(w, 4,3,3);
      print_int3(w, 7,0,2);
      print_int3(w, 5,1,0);
      print_int3(w, 3,5,1);
      print_int3(w, 4,6,0);
      print_int3(w, 2,6,1);
      print_int3(w, 4,9,1);
      print_int3(w, 8,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0x10504054 in SOP form: [5 args][5 real args] -01-0 00-10 0-110 1-100
      print_int(w, 0x10504054);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 2,0,2);
      print_int3(w, 4,1,1);
      print_int3(w, 6,3,2);
      print_int3(w, 4,1,2);
      print_int3(w, 7,0,2);
      print_int3(w, 6,5,0);
      print_int3(w, 8,5,0);
      print_int3(w, 3,5,1);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x44451515 in SOP form: [5 args][5 real args] 0-0-0 -00-0 0--00 1--10
      print_int(w, 0x44451515);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 4,0,3);
      print_int3(w, 5,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 7,0,2);
      print_int3(w, 4,9,0);
      print_int3(w, 6,8,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x1050555 in SOP form: [5 args][5 real args] 00--0 0-0-0 -00-0 --000
      print_int(w, 0x1050555);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 2,0,3);
      print_int3(w, 4,3,3);
      print_int3(w, 5,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,5,1);
      print_int3(w, 3,5,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x1bb81bb8 in SOP form: [4 args][4 real args] -0-11 --011 -010- --100 -100-
      print_int(w, 0x1bb81bb8);
      print_int(w, 4);
      print_int(w, 16);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 4,0,2);
      print_int3(w, 3,4,1);
      print_int3(w, 3,5,1);
      print_int3(w, 2,5,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x80018001 in SOP form: [4 args][4 real args] -0000 -1111
      print_int(w, 0x80018001);
      print_int(w, 4);
      print_int(w, 11);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,2);
      print_int3(w, 5,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 8,7,0);
      print_int3(w, 6,9,7);
//   Info: the reduced boolean expression 0xa041a041 in SOP form: [4 args][4 real args] -11-1 -0000 -0110
      print_int(w, 0xa041a041);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,0,3);
      print_int3(w, 4,2,2);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 3,7,0);
      print_int3(w, 4,8,0);
      print_int3(w, 6,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xe041e041 in SOP form: [4 args][4 real args] --110 -11-1 -0000
      print_int(w, 0xe041e041);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,6,0);
      print_int3(w, 3,8,0);
      print_int3(w, 7,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xa040a040 in SOP form: [4 args][4 real args] -11-1 -0110
      print_int(w, 0xa040a040);
      print_int(w, 4);
      print_int(w, 10);
      print_int3(w, 1,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 3,2,1);
      print_int3(w, 6,4,0);
      print_int3(w, 3,5,0);
      print_int3(w, 7,8,7);
//   Info: the reduced boolean expression 0xe040e040 in SOP form: [4 args][4 real args] --110 -11-1
      print_int(w, 0xe040e040);
      print_int(w, 4);
      print_int(w, 9);
      print_int3(w, 1,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,4,0);
      print_int3(w, 3,5,0);
      print_int3(w, 6,7,7);
//   Info: the reduced boolean expression 0x4c8e4c8e in SOP form: [4 args][4 real args] --01- -00-1 -0-11 -1-10
      print_int(w, 0x4c8e4c8e);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,2);
      print_int3(w, 1,0,2);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,1);
      print_int3(w, 3,6,0);
      print_int3(w, 5,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xab77ab77 in SOP form: [4 args][4 real args] -0-0- --00- -0--0 -1--1
      print_int(w, 0xab77ab77);
      print_int(w, 4);
      print_int(w, 11);
      print_int3(w, 3,1,3);
      print_int3(w, 2,1,3);
      print_int3(w, 3,0,3);
      print_int3(w, 3,0,0);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0xab77ab77 in SOP form: [4 args][4 real args] -0-0- --00- -0--0 -1--1
      print_int(w, 0xab77ab77);
      print_int(w, 4);
      print_int(w, 11);
      print_int3(w, 3,1,3);
      print_int3(w, 2,1,3);
      print_int3(w, 3,0,3);
      print_int3(w, 3,0,0);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0x5d9f5d9f in SOP form: [4 args][4 real args] -00-- ---00 --01- -1--0 -0-11
      print_int(w, 0x5d9f5d9f);
      print_int(w, 4);
      print_int(w, 14);
      print_int3(w, 3,2,3);
      print_int3(w, 3,0,2);
      print_int3(w, 1,0,3);
      print_int3(w, 1,0,0);
      print_int3(w, 2,1,1);
      print_int3(w, 3,7,1);
      print_int3(w, 4,5,7);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x1bb91bb9 in SOP form: [4 args][4 real args] ---00 -0-11 --011 -010- -100-
      print_int(w, 0x1bb91bb9);
      print_int(w, 4);
      print_int(w, 16);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,3);
      print_int3(w, 3,4,1);
      print_int3(w, 2,4,1);
      print_int3(w, 3,6,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x7fbf7fbf in SOP form: [4 args][4 real args] --0-- ---0- -0--1 -1--0
      print_int(w, 0x7fbf7fbf);
      print_int(w, 4);
      print_int(w, 9);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,4);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
//   Info: the reduced boolean expression 0x4c8e4c8e in SOP form: [4 args][4 real args] --01- -00-1 -0-11 -1-10
      print_int(w, 0x4c8e4c8e);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,2);
      print_int3(w, 1,0,2);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,1);
      print_int3(w, 3,6,0);
      print_int3(w, 5,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0x5d9e5d9e in SOP form: [4 args][4 real args] --01- -1--0 -00-1 -0-11 --100
      print_int(w, 0x5d9e5d9e);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,1);
      print_int3(w, 5,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x7fbe7fbe in SOP form: [4 args][4 real args] -0--1 --0-1 --01- --10- -1--0
      print_int(w, 0x7fbe7fbe);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,0,1);
      print_int3(w, 2,1,1);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0x15554555 in SOP form: [5 args][5 real args] -0--0 --0-0 0--10 1--00
      print_int(w, 0x15554555);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 4,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,2);
      print_int3(w, 3,0,3);
      print_int3(w, 2,0,3);
      print_int3(w, 4,6,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x1454541 in SOP form: [5 args][5 real args] --000 0-110 -0110 010-0 100-0
      print_int(w, 0x1454541);
      print_int(w, 5);
      print_int(w, 19);
      print_int3(w, 2,0,3);
      print_int3(w, 1,0,2);
      print_int3(w, 2,6,0);
      print_int3(w, 4,3,2);
      print_int3(w, 5,1,2);
      print_int3(w, 4,3,1);
      print_int3(w, 8,5,0);
      print_int3(w, 10,5,0);
      print_int3(w, 4,7,1);
      print_int3(w, 3,7,1);
      print_int3(w, 9,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
//   Info: the reduced boolean expression 0x44001000 in SOP form: [5 args][5 real args] 11-10 01100
      print_int(w, 0x44001000);
      print_int(w, 5);
      print_int(w, 12);
      print_int3(w, 3,0,2);
      print_int3(w, 2,1,2);
      print_int3(w, 4,1,0);
      print_int3(w, 7,5,0);
      print_int3(w, 4,5,1);
      print_int3(w, 9,6,0);
      print_int3(w, 8,10,7);
//   Info: the reduced boolean expression 0x54001000 in SOP form: [5 args][5 real args] -1100 11-10
      print_int(w, 0x54001000);
      print_int(w, 5);
      print_int(w, 11);
      print_int3(w, 3,0,2);
      print_int3(w, 2,1,2);
      print_int3(w, 4,1,0);
      print_int3(w, 7,5,0);
      print_int3(w, 5,6,0);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0x11514155 in SOP form: [5 args][5 real args] 00--0 --000 -01-0 1--00 0-110
      print_int(w, 0x11514155);
      print_int(w, 5);
      print_int(w, 18);
      print_int3(w, 2,0,2);
      print_int3(w, 1,0,3);
      print_int3(w, 4,3,3);
      print_int3(w, 7,0,2);
      print_int3(w, 5,1,0);
      print_int3(w, 3,5,1);
      print_int3(w, 4,6,0);
      print_int3(w, 2,6,1);
      print_int3(w, 4,9,1);
      print_int3(w, 8,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
//   Info: the reduced boolean expression 0x10504054 in SOP form: [5 args][5 real args] -01-0 00-10 0-110 1-100
      print_int(w, 0x10504054);
      print_int(w, 5);
      print_int(w, 16);
      print_int3(w, 2,0,2);
      print_int3(w, 4,1,1);
      print_int3(w, 6,3,2);
      print_int3(w, 4,1,2);
      print_int3(w, 7,0,2);
      print_int3(w, 6,5,0);
      print_int3(w, 8,5,0);
      print_int3(w, 3,5,1);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0x44451515 in SOP form: [5 args][5 real args] 0-0-0 -00-0 0--00 1--10
      print_int(w, 0x44451515);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 4,0,3);
      print_int3(w, 5,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 7,0,2);
      print_int3(w, 4,9,0);
      print_int3(w, 6,8,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x1050555 in SOP form: [5 args][5 real args] 00--0 0-0-0 -00-0 --000
      print_int(w, 0x1050555);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 2,0,3);
      print_int3(w, 4,3,3);
      print_int3(w, 5,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,5,1);
      print_int3(w, 3,5,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x1bb81bb8 in SOP form: [4 args][4 real args] -0-11 --011 -010- --100 -100-
      print_int(w, 0x1bb81bb8);
      print_int(w, 4);
      print_int(w, 16);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 4,0,2);
      print_int3(w, 3,4,1);
      print_int3(w, 3,5,1);
      print_int3(w, 2,5,1);
      print_int3(w, 7,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
//   Info: the reduced boolean expression 0xa041a041 in SOP form: [4 args][4 real args] -11-1 -0000 -0110
      print_int(w, 0xa041a041);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,0,3);
      print_int3(w, 4,2,2);
      print_int3(w, 5,1,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,1,0);
      print_int3(w, 3,7,0);
      print_int3(w, 4,8,0);
      print_int3(w, 6,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xe041e041 in SOP form: [4 args][4 real args] --110 -11-1 -0000
      print_int(w, 0xe041e041);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,6,0);
      print_int3(w, 3,8,0);
      print_int3(w, 7,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xa040a040 in SOP form: [4 args][4 real args] -11-1 -0110
      print_int(w, 0xa040a040);
      print_int(w, 4);
      print_int(w, 10);
      print_int3(w, 1,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 3,2,1);
      print_int3(w, 6,4,0);
      print_int3(w, 3,5,0);
      print_int3(w, 7,8,7);
//   Info: the reduced boolean expression 0xe040e040 in SOP form: [4 args][4 real args] --110 -11-1
      print_int(w, 0xe040e040);
      print_int(w, 4);
      print_int(w, 9);
      print_int3(w, 1,0,2);
      print_int3(w, 2,0,0);
      print_int3(w, 2,4,0);
      print_int3(w, 3,5,0);
      print_int3(w, 6,7,7);
//   Info: the reduced boolean expression 0x4c8e4c8e in SOP form: [4 args][4 real args] --01- -00-1 -0-11 -1-10
      print_int(w, 0x4c8e4c8e);
      print_int(w, 4);
      print_int(w, 13);
      print_int3(w, 3,0,1);
      print_int3(w, 4,2,2);
      print_int3(w, 1,0,2);
      print_int3(w, 4,1,0);
      print_int3(w, 2,1,1);
      print_int3(w, 3,6,0);
      print_int3(w, 5,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0x28a0a8a0 in SOP form: [5 args][5 real args] 0-1-1 -01-1 --101 -1011
      print_int(w, 0x28a0a8a0);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 2,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,5,1);
      print_int3(w, 3,5,1);
      print_int3(w, 6,8,0);
      print_int3(w, 7,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x28a0a8a0 in SOP form: [5 args][5 real args] 0-1-1 -01-1 --101 -1011
      print_int(w, 0x28a0a8a0);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 2,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,5,1);
      print_int3(w, 3,5,1);
      print_int3(w, 6,8,0);
      print_int3(w, 7,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0xa8a00820 in SOP form: [5 args][5 real args] 1-1-1 -0101 -1011
      print_int(w, 0xa8a00820);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 2,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,5,0);
      print_int3(w, 3,7,1);
      print_int3(w, 6,8,0);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0xa8a0a820 in SOP form: [5 args][5 real args] --101 -1-11 1-1-1
      print_int(w, 0xa8a0a820);
      print_int(w, 5);
      print_int(w, 12);
      print_int3(w, 2,0,0);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,5,0);
      print_int3(w, 3,7,0);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0xa8a0a820 in SOP form: [5 args][5 real args] --101 -1-11 1-1-1
      print_int(w, 0xa8a0a820);
      print_int(w, 5);
      print_int(w, 12);
      print_int3(w, 2,0,0);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,5,0);
      print_int3(w, 3,7,0);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0xaaaac800 in SOP form: [5 args][5 real args] 1---1 -1-11 0111-
      print_int(w, 0xaaaac800);
      print_int(w, 5);
      print_int(w, 12);
      print_int3(w, 3,1,0);
      print_int3(w, 4,0,0);
      print_int3(w, 5,0,0);
      print_int3(w, 5,2,0);
      print_int3(w, 4,8,1);
      print_int3(w, 6,7,7);
      print_int3(w, 9,10,7);
//   Info: the reduced boolean expression 0xaa0a80a0 in SOP form: [5 args][5 real args] 1-0-1 11--1 001-1 0-111
      print_int(w, 0xaa0a80a0);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 2,0,0);
      print_int3(w, 4,0,0);
      print_int3(w, 4,5,1);
      print_int3(w, 7,3,2);
      print_int3(w, 6,2,2);
      print_int3(w, 7,1,0);
      print_int3(w, 6,3,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0xa288a288 in SOP form: [4 args][4 real args] -0-11 --111 -1-01
      print_int(w, 0xa288a288);
      print_int(w, 4);
      print_int(w, 11);
      print_int3(w, 1,0,0);
      print_int3(w, 3,1,2);
      print_int3(w, 5,0,0);
      print_int3(w, 2,4,0);
      print_int3(w, 3,4,1);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
//   Info: the reduced boolean expression 0x8a288a28 in SOP form: [4 args][4 real args] --011 -10-1 -1-11 -0101
      print_int(w, 0x8a288a28);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 5,0,0);
      print_int3(w, 6,0,0);
      print_int3(w, 3,4,0);
      print_int3(w, 2,4,1);
      print_int3(w, 3,8,1);
      print_int3(w, 7,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0xa88aa000 in SOP form: [5 args][5 real args] -11-1 1--11 100-1
      print_int(w, 0xa88aa000);
      print_int(w, 5);
      print_int(w, 13);
      print_int3(w, 4,0,0);
      print_int3(w, 5,3,2);
      print_int3(w, 6,2,2);
      print_int3(w, 2,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 3,8,0);
      print_int3(w, 7,9,7);
      print_int3(w, 10,11,7);
//   Info: the reduced boolean expression 0xaaa888aa in SOP form: [5 args][5 real args] ---11 00--1 -01-1 11--1
      print_int(w, 0xaaa888aa);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 3,0,1);
      print_int3(w, 1,0,0);
      print_int3(w, 3,0,0);
      print_int3(w, 5,2,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,7,0);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0xaaa888aa in SOP form: [5 args][5 real args] ---11 00--1 -01-1 11--1
      print_int(w, 0xaaa888aa);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 3,0,1);
      print_int3(w, 1,0,0);
      print_int3(w, 3,0,0);
      print_int3(w, 5,2,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,7,0);
      print_int3(w, 6,8,7);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0xa80a0 in SOP form: [5 args][5 real args] 001-1 0-111 100-1
      print_int(w, 0xa80a0);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 2,0,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,3,2);
      print_int3(w, 6,3,2);
      print_int3(w, 7,2,2);
      print_int3(w, 9,0,0);
      print_int3(w, 6,1,0);
      print_int3(w, 8,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0xa80a0 in SOP form: [5 args][5 real args] 001-1 0-111 100-1
      print_int(w, 0xa80a0);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 2,0,0);
      print_int3(w, 4,5,1);
      print_int3(w, 4,3,2);
      print_int3(w, 6,3,2);
      print_int3(w, 7,2,2);
      print_int3(w, 9,0,0);
      print_int3(w, 6,1,0);
      print_int3(w, 8,10,7);
      print_int3(w, 11,12,7);
//   Info: the reduced boolean expression 0x7ffe7ffe in SOP form: [4 args][4 real args] -0--1 -0-1- ---10 -01-- --10- -10--
      print_int(w, 0x7ffe7ffe);
      print_int(w, 4);
      print_int(w, 15);
      print_int3(w, 3,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 3,0,1);
      print_int3(w, 3,1,1);
      print_int3(w, 3,2,1);
      print_int3(w, 4,5,7);
      print_int3(w, 6,7,7);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x69866986 in SOP form: [4 args][4 real args] -0001 -0010 -0111 -1000 -1011 -1101 -1110
      print_int(w, 0x69866986);
      print_int(w, 4);
      print_int(w, 25);
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 1,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 1,0,1);
      print_int3(w, 3,2,0);
      print_int3(w, 4,1,2);
      print_int3(w, 10,0,2);
      print_int3(w, 3,2,1);
      print_int3(w, 5,6,0);
      print_int3(w, 9,6,0);
      print_int3(w, 4,7,0);
      print_int3(w, 12,7,0);
      print_int3(w, 5,8,0);
      print_int3(w, 9,8,0);
      print_int3(w, 11,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
      print_int3(w, 22,23,7);
//   Info: the reduced boolean expression 0x177e177e in SOP form: [4 args][4 real args] -00-1 -001- -0-10 --010 -010- --100 -100-
      print_int(w, 0x177e177e);
      print_int(w, 4);
      print_int(w, 21);
      print_int3(w, 3,2,3);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 3,2,2);
      print_int3(w, 7,1,2);
      print_int3(w, 5,0,2);
      print_int3(w, 4,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 3,5,1);
      print_int3(w, 3,6,1);
      print_int3(w, 2,6,1);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0x70e0e080 in SOP form: [5 args][5 real args] 0-111 011-1 0111- -1110 101-1 1011- 1110-
      print_int(w, 0x70e0e080);
      print_int(w, 5);
      print_int(w, 26);
      print_int3(w, 2,1,0);
      print_int3(w, 4,3,2);
      print_int3(w, 2,0,0);
      print_int3(w, 4,3,1);
      print_int3(w, 2,1,2);
      print_int3(w, 3,0,2);
      print_int3(w, 5,0,0);
      print_int3(w, 4,3,0);
      print_int3(w, 6,5,0);
      print_int3(w, 8,5,0);
      print_int3(w, 10,5,0);
      print_int3(w, 6,7,0);
      print_int3(w, 8,7,0);
      print_int3(w, 12,9,0);
      print_int3(w, 4,11,1);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
//   Info: the reduced boolean expression 0x8117 in SOP form: [5 args][5 real args] 0000- 000-0 00-00 0-000 01111
      print_int(w, 0x8117);
      print_int(w, 5);
      print_int(w, 21);
      print_int3(w, 4,3,3);
      print_int3(w, 5,2,2);
      print_int3(w, 1,0,3);
      print_int3(w, 4,2,3);
      print_int3(w, 6,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 5,7,0);
      print_int3(w, 8,7,0);
      print_int3(w, 12,11,0);
      print_int3(w, 4,15,1);
      print_int3(w, 9,10,7);
      print_int3(w, 13,14,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0x7ffe in SOP form: [5 args][5 real args] 00--1 00-1- 0--10 001-- 0-10- 010--
      print_int(w, 0x7ffe);
      print_int(w, 5);
      print_int(w, 20);
      print_int3(w, 4,3,3);
      print_int3(w, 3,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 5,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 5,2,0);
      print_int3(w, 4,6,1);
      print_int3(w, 4,7,1);
      print_int3(w, 4,8,1);
      print_int3(w, 9,10,7);
      print_int3(w, 11,12,7);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
//   Info: the reduced boolean expression 0x80017ffe in SOP form: [5 args][5 real args] 00--1 00-1- 0--10 001-- 0-10- 010-- 10000 11111
      print_int(w, 0x80017ffe);
      print_int(w, 5);
      print_int(w, 30);
      print_int3(w, 4,3,3);
      print_int3(w, 4,3,2);
      print_int3(w, 3,2,2);
      print_int3(w, 6,2,2);
      print_int3(w, 2,1,2);
      print_int3(w, 8,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 10,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 5,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 3,2,0);
      print_int3(w, 5,2,0);
      print_int3(w, 4,7,1);
      print_int3(w, 4,9,1);
      print_int3(w, 4,11,1);
      print_int3(w, 4,13,0);
      print_int3(w, 21,16,0);
      print_int3(w, 12,14,7);
      print_int3(w, 15,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,22,7);
      print_int3(w, 23,24,7);
      print_int3(w, 25,26,7);
      print_int3(w, 27,28,7);
//   Info: the reduced boolean expression 0x7ee87ee8 in SOP form: [4 args][4 real args] -0-11 -01-1 -011- --110 -10-1 -101- -110-
      print_int(w, 0x7ee87ee8);
      print_int(w, 4);
      print_int(w, 21);
      print_int3(w, 3,2,2);
      print_int3(w, 3,0,1);
      print_int3(w, 2,1,0);
      print_int3(w, 2,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 4,0,0);
      print_int3(w, 4,1,0);
      print_int3(w, 5,1,0);
      print_int3(w, 5,2,0);
      print_int3(w, 3,6,1);
      print_int3(w, 3,7,0);
      print_int3(w, 8,9,7);
      print_int3(w, 10,11,7);
      print_int3(w, 12,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0x69826982 in SOP form: [4 args][4 real args] -0001 -0111 -1000 -1011 -1101 -1110
      print_int(w, 0x69826982);
      print_int(w, 4);
      print_int(w, 23);
      print_int3(w, 3,2,2);
      print_int3(w, 1,0,0);
      print_int3(w, 1,0,1);
      print_int3(w, 3,2,0);
      print_int3(w, 3,2,3);
      print_int3(w, 4,1,2);
      print_int3(w, 1,0,2);
      print_int3(w, 9,0,2);
      print_int3(w, 3,2,1);
      print_int3(w, 4,5,0);
      print_int3(w, 12,5,0);
      print_int3(w, 7,6,0);
      print_int3(w, 8,6,0);
      print_int3(w, 7,10,0);
      print_int3(w, 11,13,7);
      print_int3(w, 14,15,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
      print_int3(w, 20,21,7);
//   Info: the reduced boolean expression 0x80020022 in SOP form: [5 args][5 real args] 00-01 -0001 11111
      print_int(w, 0x80020022);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 3,1,3);
      print_int3(w, 5,0,0);
      print_int3(w, 6,2,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,6,1);
      print_int3(w, 4,8,0);
      print_int3(w, 11,9,0);
      print_int3(w, 7,10,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x80000022 in SOP form: [5 args][5 real args] 00-01 11111
      print_int(w, 0x80000022);
      print_int(w, 5);
      print_int(w, 13);
      print_int3(w, 4,3,3);
      print_int3(w, 5,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 6,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,7,0);
      print_int3(w, 10,9,0);
      print_int3(w, 8,11,7);
//   Info: the reduced boolean expression 0x80000002 in SOP form: [5 args][5 real args] 00001 11111
      print_int(w, 0x80000002);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 4,3,3);
      print_int3(w, 5,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 1,0,0);
      print_int3(w, 7,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,8,0);
      print_int3(w, 11,10,0);
      print_int3(w, 9,12,7);
//   Info: the reduced boolean expression 0x2aa8a880 in SOP form: [5 args][5 real args] 0-111 01-11 011-1 -1101 10-11 101-1 110-1
      print_int(w, 0x2aa8a880);
      print_int(w, 5);
      print_int(w, 26);
      print_int3(w, 2,0,0);
      print_int3(w, 4,3,2);
      print_int3(w, 1,0,0);
      print_int3(w, 4,3,1);
      print_int3(w, 3,2,2);
      print_int3(w, 3,1,2);
      print_int3(w, 4,0,0);
      print_int3(w, 5,1,0);
      print_int3(w, 6,5,0);
      print_int3(w, 8,5,0);
      print_int3(w, 10,5,0);
      print_int3(w, 6,7,0);
      print_int3(w, 8,7,0);
      print_int3(w, 11,9,0);
      print_int3(w, 4,12,1);
      print_int3(w, 13,14,7);
      print_int3(w, 15,16,7);
      print_int3(w, 17,18,7);
      print_int3(w, 19,20,7);
      print_int3(w, 21,22,7);
      print_int3(w, 23,24,7);
//   Info: the reduced boolean expression 0x8010107 in SOP form: [5 args][5 real args] 0000- 000-0 0-000 -0000 11011
      print_int(w, 0x8010107);
      print_int(w, 5);
      print_int(w, 21);
      print_int3(w, 4,2,3);
      print_int3(w, 5,3,2);
      print_int3(w, 1,0,3);
      print_int3(w, 3,2,2);
      print_int3(w, 3,2,3);
      print_int3(w, 6,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 5,7,0);
      print_int3(w, 9,7,0);
      print_int3(w, 4,8,0);
      print_int3(w, 15,12,0);
      print_int3(w, 10,11,7);
      print_int3(w, 13,14,7);
      print_int3(w, 16,17,7);
      print_int3(w, 18,19,7);
//   Info: the reduced boolean expression 0x80070000 in SOP form: [5 args][5 real args] 1000- 100-0 11111
      print_int(w, 0x80070000);
      print_int(w, 5);
      print_int(w, 15);
      print_int3(w, 4,3,2);
      print_int3(w, 5,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 6,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,9,0);
      print_int3(w, 11,10,0);
      print_int3(w, 7,8,7);
      print_int3(w, 12,13,7);
//   Info: the reduced boolean expression 0x80050000 in SOP form: [5 args][5 real args] 100-0 11111
      print_int(w, 0x80050000);
      print_int(w, 5);
      print_int(w, 13);
      print_int3(w, 4,3,2);
      print_int3(w, 5,2,2);
      print_int3(w, 6,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,8,0);
      print_int3(w, 10,9,0);
      print_int3(w, 7,11,7);
//   Info: the reduced boolean expression 0x80010000 in SOP form: [5 args][5 real args] 10000 11111
      print_int(w, 0x80010000);
      print_int(w, 5);
      print_int(w, 14);
      print_int3(w, 4,3,2);
      print_int3(w, 5,2,2);
      print_int3(w, 6,1,2);
      print_int3(w, 7,0,2);
      print_int3(w, 1,0,0);
      print_int3(w, 3,2,0);
      print_int3(w, 4,9,0);
      print_int3(w, 11,10,0);
      print_int3(w, 8,12,7);

   fclose(w);
   return 0;
}
