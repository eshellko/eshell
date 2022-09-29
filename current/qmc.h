// Q: eprint without special symbols which can only be written into printf file?
//    special handling internally!?

#define __PRINT__

// Source: https://github.com/AkshayRaman/Quine-McCluskey-algorithm/blob/master/Quine-McClusky.cpp
#include <vector>

// Note: MAX number of input terms...
#ifndef TERMS_NUM
   #define TERMS_NUM 5
   typedef unsigned int type_t;
   #define QMC_MASK 0x1F
// // TODO: extend to6 and more...
// #define TERMS_NUM 6
// typedef unsigned long int type_t;
// #define QMC_MASK 0x3F
#endif
//==================================
//
//
//
//==================================
						      void print_product(type_t);
// function to check if two terms differ by just one bit
bool isGreyCode(type_t a, type_t b)
{
   int flag=0;
//#define __ONLY_MEANING__
#ifdef __ONLY_MEANING__
   for(int i=0; i < TERMS_NUM; i++)
   {
      if(   ((a & (1<<i)) != (b & (1<<i)))  || ((a & (1<<(i+TERMS_NUM))) != (b & (1<<(i+TERMS_NUM))))  )
         flag++;
   }
#else
   for(int i=0; i < TERMS_NUM * 2; i++)
   {
      if((a & (1<<i)) != (b & (1<<i)))
         flag++;
   }
#endif
/*
if(flag==1)
{
printf("\t\t:::");
print_product(a);
printf("\n\t\t   ");
print_product(b);
printf("\n");
}*/
   return (flag==1);
}
// function to check if string b exists in vector a
bool in_vector(std::vector<type_t> a, type_t b)
{
   int sz = a.size();
   for(int i=0; i<sz; i++)
      if(a[i] == b)
         return true;
   return false;
}
// function to replace complement terms with don't cares
// Eg: 0110 and 0111 becomes 011-
int replace_complements(type_t a, type_t b)
{
   type_t temp = 0;
   for(int i=0; i<TERMS_NUM; i++)
      if(((a & (1<<i)) != (b & (1<<i))) && (!(a & (1<<(TERMS_NUM+i))) && !(b & (1<<(TERMS_NUM+i)))))
         temp = (temp | (1 << (TERMS_NUM+i))) & ~(1 << i);
      else
         temp = temp | (a & (1<<i)) | (a & (1<<(TERMS_NUM+i))); // TODO: keep DC as well
   return temp;
}
// function to reduce minterms
std::vector<type_t> reduce(std::vector<type_t> minions)
{
   std::vector<type_t> newminions;
// printf("\nStep\n");
   int max = minions.size();
   type_t* checked = new type_t[max]; // TODO: use MSB to mark...
   for(int i=0; i<max; i++) checked[i] = 0;
   for(int i=0; i<max; i++)
   {
// printf("term % 4x : ", minions[i]);
// print_product(minions[i]);
// printf("\n");
      for(int j=i; j<max; j++)
      {
         // If a grey code pair is found, replace the differing bit with don't cares.
         if(isGreyCode(minions[i],minions[j]))
         {
            checked[i]=1;
            checked[j]=1;
            if(!in_vector(newminions, replace_complements(minions[i],minions[j])))
               newminions.push_back(replace_complements(minions[i],minions[j]));
         }
      }
   }

// printf("\nExit\n");
   // appending all reduced terms to a new vector
   for(int i=0; i<max; i++)
   {
      if(checked[i]!=1)
      if(! in_vector(newminions,minions[i])) // BUGGED line
         newminions.push_back(minions[i]);
   }
   delete[] checked;
/*
   for(int i=0; i<newminions.size(); i++)
   {
printf("term % 4x : ", newminions[i]);
print_product(newminions[i]);
printf("\n");
   }
*/
   return newminions;
}
// function to check if 2 vectors are equal
bool VectorsEqual(std::vector<type_t> a, std::vector<type_t> b)
{
   if(a.size() != b.size())
      return false;

   std::sort(a.begin(),a.end());
   std::sort(b.begin(),b.end());
   int sz = a.size();
   for(int i=0; i<sz; i++)
   {
      if(a[i] != b[i])
         return false;
   }
   return true;
}

void print_product(type_t minions)
{
   for(int u = TERMS_NUM - 1; u>=0; u--)
   {
      if(  (minions & (1<<(TERMS_NUM+u))) &&  (minions & (1<<(u)))) eprint("-"); // X
      if(  (minions & (1<<(TERMS_NUM+u))) && !(minions & (1<<(u)))) eprint("-"); // X
      if( !(minions & (1<<(TERMS_NUM+u))) &&  (minions & (1<<(u)))) eprint("1");
      if( !(minions & (1<<(TERMS_NUM+u))) && !(minions & (1<<(u)))) eprint("0");
   }
}

void prepare_product(int arr[32][5], type_t minions, int i)
{
   int pos = 0;
   for(int u = TERMS_NUM - 1; u>=0; u--)
   {
      if( !(minions & (1<<(TERMS_NUM+u))) &&  (minions & (1<<(u)))) arr[i][pos++] = u+1;
      if( !(minions & (1<<(TERMS_NUM+u))) && !(minions & (1<<(u)))) arr[i][pos++] = -(u+1);
   }
}

//======================================
//
//======================================
void eqmc(/*unsigned */type_t minterm)
{
   /*unsigned */type_t mc = minterm;
#ifdef __PRINT__
   eprint("//   Info: the reduced boolean expression 0x%lx in SOP form: ", minterm);
#endif
   int i;
   std::vector<type_t>    minions; // 16 LSB for data, 16 MSB for don't-cares
   type_t value = 0;
   while(minterm)
   {
      if(minterm & 0x1)
         minions.push_back(value);
      value++;
      minterm >>= 1;
   }

// Note: repeat reduction until no improve detected
   while(1)
   {
      std::vector<type_t> old_minions = minions;
if(minions.size()==0)return;
      minions = reduce(minions); // TODO: free previous structure
      if(VectorsEqual(minions, old_minions))
         break;
   }
//
// Step 2. find essential prime implicants
//
/*
   eprint("Essentials:\n");
   printf("          1111111111222222222233\n");
   printf("01234567890123456789012345678901\n");
   for(i=0; i<minions.size(); i++)
   {
      for(int j=0; j < (1<<TERMS_NUM); j++)
      {
	 if((minions[i] & QMC_MASK) == j) printf("v"); // direct match
	 else if((minions[i] & QMC_MASK) == (j & ~(minions[i] >> TERMS_NUM))) printf("v"); // ignore dont care
	 else printf(" ");
      }
      eprint("  ");
      print_product(minions[i]);
      eprint("\n");
   }
*/
   type_t y = mc;
   for(type_t j=0; j < (1L<<TERMS_NUM); j++)
   {
// printf("y = %x\n", y);
      int covers = 0;
      // count potential minterms
      int sz = minions.size();
      if(y & (1L<<j))
      for(i=0; i<sz; i++)
      {
	 if((minions[i] & QMC_MASK) == j) covers++;
	 else if((minions[i] & QMC_MASK) == (j & ~(minions[i] >> TERMS_NUM))) covers++;
      }
      // if only one -> essential minterm -> exclude covered positions from RV and repeat until no ones left...
      if(covers == 1)
      {
//          printf("ess: ");
         for(i=0; i<sz; i++)
         {
            if( ((minions[i] & QMC_MASK) == j) || ((minions[i] & QMC_MASK) == (j & ~(minions[i] >> TERMS_NUM))))
	    {
// 	       print_product(minions[i]);
minions[i] |= 0x80000000; // MSB - mark essential
	    }
         }
//          eprint("\n");

         for(i=0; i<sz; i++)
         {
            if(minions[i] & 0x80000000)
               for(type_t k=0; k < (1L<<TERMS_NUM); k++)
	          if( ((minions[i] & QMC_MASK) == k) || ((minions[i] & QMC_MASK) == (k & ~(minions[i] >> TERMS_NUM))))
	          {
                     y &= ~(1L << k); // exclude others of ESSENTIAL minterm
	          }
         }
      }
   }
// choose non-essential implicants (TODO: select existing combinations, when possible at AIG)
   /*for(i=0; i<minions.size(); i++)
   {
      if(!(minions[i] & 0x80000000))
      {
	 eprint("non-essential: ");
         print_product(minions[i]);
	 eprint("\n");
      }
   }*/
   for(type_t j=0; j < (1L<<TERMS_NUM); j++)
   {
      // count potential minterms
      if(y & (1<<j))
      {
// printf("y = %x\n", y);
         int sz = minions.size();
         for(i=0; i<sz; i++)
         {
            if( ((minions[i] & QMC_MASK) == j) || ((minions[i] & QMC_MASK) == (j & ~(minions[i] >> TERMS_NUM))))
	    {
// 	       print_product(minions[i]);
               minions[i] |= 0x80000000; // MSB - mark essential
               for(type_t k=0; k < (1L<<TERMS_NUM); k++)
	          if( ((minions[i] & QMC_MASK) == k) || ((minions[i] & QMC_MASK) == (k & ~(minions[i] >> TERMS_NUM))))
	          {
                     y &= ~(1L << k); // exclude others of ESSENTIAL minterm
	          }
//                eprint("\n");
// printf("y = %x\n", y);
               if(!(y & (1L<<j))) break;
	    }
         }
      }
   }

   std::vector<type_t> newminions;
   int sz = minions.size();
   for(i=0; i<sz; i++)
   {
      if(!(minions[i] & 0x80000000))
      {
/*
	 eprint("redundant: ");
         print_product(minions[i]);
	 eprint("\n");
*/
      }
      else
         newminions.push_back(minions[i]);
   }
   minions = newminions;

/*
Essentials:
          1111111111222222222233
01234567890123456789012345678901
 *   v   v   v                    0--01*
    *-      --                    0-10-*
        ---*                      010--*
        --  --                    01-0-   redundant
        v - v *                   01--0*
  *       v                       0-010*
     - *                          001-1*
                *                 10000*
*/


// Note: define if MSB is DC, then number of inputs can be reduced by 1 (Q: some functions may not use MSB but CUTed with it?)
   int num = TERMS_NUM;
   sz = minions.size();
   for(i = TERMS_NUM-1; i>=0; i--)
   {
      bool is_dc = true;
      for(int u=0; u<sz; u++)
      {
         if(!(minions[u] & (1 << (TERMS_NUM+i)))) is_dc = false;
      }
      if(is_dc) num--;
      else break;
   }
#ifdef __PRINT__
   eprint("[%d args]", num);
#endif

// Note: define if MSB is DC, then number of inputs can be reduced by 1 9Q: some functions may not use MSB but CUTed with it?)
   num = TERMS_NUM;
   sz = minions.size();
   for(i = TERMS_NUM-1; i>=0; i--)
   {
      bool is_dc = true;
      for(int u=0; u<sz; u++)
      {
         if(!(minions[u] & (1 << (TERMS_NUM+i)))) is_dc = false;
      }
      if(is_dc) num--;
   }
#ifdef __PRINT__
   eprint("[%d real args]", num);

   for(i=0; i<sz; i++)
   {
      eprint(" ");
      print_product(minions[i]);
   }
   eprint("\n");
#endif

//=============================
// ML  :-) create updated cut for this case
//=============================
   int arr[32][5] = {0};
//   eprint("   Info: add following code into 'cut.cpp. as part of ML'.\n");
   eprint("      print_int(w, 0x%lx);\n", mc);
   eprint("      print_int(w, %d);\n", num);
   for(i=0; i<sz; i++)
      prepare_product(arr, minions[i], i);
   sop_core(arr);
   eprint("      >>> see previous code >>> print_int(w, 12);\n");
}
