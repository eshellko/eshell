#include "stdio.h"
#include "stdlib.h"
#include <map>
#include <set>

// Note: define to print more debug info
//#define __REPORT__

void print(int arr[32][5], int num_clause)
{
#ifdef __REPORT__
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
#ifdef __REPORT__
      printf("Alias+ : %d = (", num_nodes);
      printf("%d, ", *it);
#endif
int a = *it;
      ite = it;
      it++;
      nodes.erase(ite);
#ifdef __REPORT__
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

int core(int arr[32][5], int num_clause, int& num_nodes)
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
#ifdef __REPORT__
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

#ifdef __REPORT__
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
#ifdef __REPORT__
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
#ifdef __REPORT__
   printf("==============\n");
#endif
// iteratively apply CSE for pair with highest weight - O(n*n) - and rerun algorithm on new array
   core(arr, num_clause, num_nodes);

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
// display
#ifdef __REPORT__
   printf("expression has %d product(s) and %d node(s):\n", num_clause, num_nodes);
#endif
   print(arr, num_clause);
#ifdef __REPORT__
   printf("==============\n");
#endif

   core(arr, num_clause, num_nodes);

#ifdef __REPORT__
   printf("SOP has %d product(s) and %d node(s):\n", num_clause, num_nodes);
#endif
   print(arr, num_clause);
#ifdef __REPORT__
   printf("==============\n");
#endif

   sop(arr, num_clause, num_nodes);
#ifdef __REPORT__
   printf("Expression has %d node(s).\n", num_nodes);
#endif

   printf("      print_int(w, %d);\n", num_nodes);

   return 0;
}

#ifndef LOCAL_SOP
int main()
{
   int arr[32][5] = {0};
// prepare example
   arr[0][0]=1;  arr[0][1]=2; arr[0][2]=3; arr[0][3]=4;  arr[0][4]=5;
   arr[1][0]=-1; arr[1][1]=2; arr[1][2]=3; arr[1][3]=-4; arr[1][4]=-5;

   return sop_core(arr);
}
#endif
