#include "stdio.h"
#include "stdlib.h"
#include <map>
#include <set>

// Note: define to print more debug info
//#define __PRINT__

void print(int arr[32][5], int num_clause)
{
#ifdef __PRINT__
   int i, j;
   for(int i=0; i<num_clause; i++)
   {
      if(arr[i][0] || arr[i][1] || arr[i][2] || arr[i][3] || arr[i][4])
      {
         for(int j=0; j<5; j++)
         {
            if(arr[i][j])
               printf("%d", arr[i][j]);
            if(arr[i][j] < 0)
               printf("'");
            if(j < 4)
               printf(" ");
         }
         printf("\n");
      }
   }
#endif
}
//===============================
// Sum Of Products (SOP)
// Creates sums (OR) of provided arguments (previously made from products (ANDs))
//===============================
void sop(int arr[32][5], int num_clause, int& num_nodes)
{
   std::set<int> nodes;
   for(int i=0; i<num_clause; i++)
      for(int j=0; j<5; j++)
          if(arr[i][j])
              nodes.insert(arr[i][j]);

   std::set<int>::iterator it = nodes.begin();
   std::set<int>::iterator ite;
//   for(it = nodes.begin(); it != nodes.end(); it++) printf("%d\n", *it);
   while(nodes.size() > 1)
   { // Q: make sure order is tree, and not linear
      num_nodes++;
#ifdef __PRINT__
      printf("Alias+ : %d = (", num_nodes);
      printf("%d, ", *it);
#endif
int a = *it;
      ite = it;
      it++;
      nodes.erase(ite);
#ifdef __PRINT__
      printf("%d)\n", *it);
#endif
int b = *it;
int opcode = 7;
if(a < 0) { opcode ^= 1; a=-a; }
if(b < 0) { opcode ^= 2; b=-b; }
printf("      print_int3(w, %d,%d,%d);\n", a-1,b-1,opcode);

      ite = it;
      nodes.insert(num_nodes);
      nodes.erase(ite);
      it = nodes.begin();
   }
//printf("%ld\n", nodes.size());
}
//===============================
// Common Subexpression Elimination (CSE) Core
// Searches for most common used pairs, and creates intermediate variable (alias) for them.
// Runs iteratively until there are pairs.
//===============================
int core_cse(int arr[32][5], int num_clause, int& num_nodes)
{
// get highest index - say up to 32+32'
// count pairs presence
   std::map<int,int> prs;
   for(int i=0; i<num_clause; i++)
      for(int j=0; j<5; j++)
         for(int k=j+1; k<5; k++)
             if(j != k)
             {
                if(arr[i][j] && arr[i][k])
                {
                    int index = 0;
                    index = (arr[i][j] & 0xFFFF) | ((arr[i][k] & 0xFFFF) << 16);
                    prs[index]++;
                }
             }
   std::map<int,int>::iterator it;
   for(it = prs.begin(); it != prs.end(); it++)
   {
      short a = it->first & 0xFFFF;
      short b = (it->first >> 16) & 0xFFFF;
#ifdef __PRINT__
      if(a > 0 && b > 0) printf("(%d,%d) = %d\n", a, b, it->second);
      else if(a > 0 && b < 0) printf("(%d,%d') = %d\n", a, -b, it->second);
      else if(a < 0 && b > 0) printf("(%d',%d) = %d\n", -a, b, it->second);
      else if(a < 0 && b < 0) printf("(%d',%d') = %d\n", -a, -b, it->second);
#endif
   }
// highest presence is...
   int high_presence = 0;
   for(it = prs.begin(); it != prs.end(); it++)
   {
       if(high_presence < it->second)
          high_presence = it->second;
   }
   // no pairs left, only products...
   if(high_presence == 0) return 0;

#ifdef __PRINT__
   printf("highest pair presence is %d\n", high_presence);
#endif

// create alias for selected pair - highest index = (%d,%d) -> print formatted string
   for(it = prs.begin(); it != prs.end(); it++)
   {
       if(high_presence == it->second)
          break;
   }

   short a = it->first & 0xFFFF;
   short b = (it->first >> 16) & 0xFFFF;
   num_nodes++;
#ifdef __PRINT__
   printf("Alias : %d = (%d,%d)\n", num_nodes, a, b);
#endif

   int opcode = 0;
   short an = a;
   short bn = b;
   if(an < 0) { opcode += 1; an=-an; }
   if(bn < 0) { opcode += 2; bn=-bn; }
   printf("      print_int3(w, %d,%d,%d);\n", an-1,bn-1,opcode);

// find pair and substitute with alias
   for(int i=0; i<num_clause; i++)
      for(int j=0; j<5; j++)
         for(int k=j+1; k<5; k++)
             if(arr[i][j]==a && arr[i][k]==b)
             {
                arr[i][k] = 0;
                arr[i][j] = num_nodes;
             }

   prs.clear();
#ifdef __PRINT__
   printf("==============\n");
#endif
// iteratively apply CSE for pair with highest weight - O(n*n) - and rerun algorithm on new array
   core_cse(arr, num_clause, num_nodes);

   return 0;
}

int sop_core(int arr[32][5])
{
   int num_clause = 0;
   int num_nodes = 0;
// get clause count
   for(int i=0; i<32; i++)
      if(arr[i][0] || arr[i][1] || arr[i][2] || arr[i][3] || arr[i][4])
         num_clause = i+1;
// get nodes count
   for(int i=0; i<32; i++)
      for(int j=0; j<5; j++)
      {
         if(arr[i][j] > 0 && arr[i][j] > num_nodes)
            num_nodes = arr[i][j];
         if(arr[i][j] < 0 && (-arr[i][j]) > num_nodes)
            num_nodes = -arr[i][j];
      }
#ifdef __PRINT__
   printf("expression has %d product(s) and %d node(s):\n", num_clause, num_nodes);
#endif
   print(arr, num_clause);
#ifdef __PRINT__
   printf("==============\n");
#endif

   core_cse(arr, num_clause, num_nodes);

#ifdef __PRINT__
   printf("SOP has %d product(s) and %d node(s):\n", num_clause, num_nodes);
#endif
   print(arr, num_clause);
#ifdef __PRINT__
   printf("==============\n");
#endif

   sop(arr, num_clause, num_nodes);
#ifdef __PRINT__
   printf("Expression has %d node(s).\n", num_nodes);
#endif

   printf("      print_int(w, %d); // move to 3rd position in section\n", num_nodes);

   return 0;
}
