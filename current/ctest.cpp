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
using namespace std;

#define eprint printf
#include "qmc.h"
int main ()
{
//   for(int i=0; i<0x100000; i++) eqmc(i);
//   for(int i=0x17fb6; i<0x18000; i++) eqmc(i);
   type_t rv = 0x76b1d25f; // 0x1111111111111111L;
   eqmc(rv);

   return 0;
}
