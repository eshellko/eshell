#include <string.h>
#include <iostream>
#include <string>
#include <vector>
#include <iomanip>
#include <algorithm>
#include <iterator>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <cstring>
#include <math.h>
//#include <vector>
using namespace std;

#define eprint printf

#define LOCAL_SOP
#include "sop.cpp"
#undef LOCAL_SOP

#include "qmc.h"
//
//
//
// TODO: produce BIN, and append original one, which will overwrite non-optimal QMC output
//       as we need to produce better result for mapping: XOR, factoring, delay_based balance...
int main ()
{
//   for(int i=0; i<0x100000; i++) eqmc(i);
//   for(int i=0x17fb6; i<0x18000; i++) eqmc(i);
type_t rv = 0x40801020;
//type_t rv = 0x1111111111111111L;
eqmc(rv);

// Q: create local AIG for given expression and optimize it independently!? it will not give optimal, as in case with original design?
//    also we can factor relative to every design to get best design? And select best after this!?
   return 0;
}

// Q: when 5 inputs, but function shows dependency on 3 or 4 of them... indexes will be reduced!?

