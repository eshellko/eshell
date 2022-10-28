#include "stdio.h"
#include "stdlib.h"
#include "vector"

void print_sop(std::vector<int>& v)
{
   int v_size = v.size();
   for(int u = 0; u < v_size; u++)
   {
      if(!(v[u] & 0x200)) printf("a%c", v[u] & 0x10 ? ' ' : '\'');
      if(!(v[u] & 0x100)) printf("b%c", v[u] & 0x8  ? ' ' : '\'');
      if(!(v[u] & 0x80))  printf("c%c", v[u] & 0x4  ? ' ' : '\'');
      if(!(v[u] & 0x40))  printf("d%c", v[u] & 0x2  ? ' ' : '\'');
      if(!(v[u] & 0x20))  printf("e%c", v[u] & 0x1  ? ' ' : '\'');
      if(u != v_size - 1) printf(" + ");
   }
}

char get_pin_name(int idx)
{
   return
      idx == 0 ? 'e' :
      idx == 1 ? 'd' :
      idx == 2 ? 'c' :
      idx == 3 ? 'b' :
      idx == 4 ? 'a' : '?';
}

void fsop5_rel(std::vector<int>& v, int i, int j, int k, int m, int n, int space=0)
{
   if(i < 0) return;

   int v_size = v.size();

   for(int i=0;i<space;i++)printf(" "); printf("-->factor relative to '%c'\n", get_pin_name(i));
   std::vector<int> i_pos;
   std::vector<int> i_neg;
   std::vector<int> def;

      for(int u = 0; u < v_size; u++)
      {
        if(!(v[u] & (1 << (i+5))))
        {
           if(v[u] & (1 << (i))) i_pos.push_back((v[u] | (1 << (i+5))) & ~(1 << i));
           else                  i_neg.push_back((v[u] | (1 << (i+5))) & ~(1 << i));
        }
        else def.push_back(v[u]);
      }

      for(int i=0;i<space;i++)printf(" "); printf("   pos: %d; neg: %d; def: %d :::: ", i_pos.size(), i_neg.size(), def.size());
      if(i_pos.size() > 0) // Q: only if more than 1!! as otherwise it is not factorization
      {
         printf("%c (", get_pin_name(i));
         print_sop(i_pos);
         printf(")");
      }
      if((i_pos.size() > 0) && ((i_neg.size() > 0) || (def.size() > 0))) printf(" + ");

      if(i_neg.size() > 0) // Q: only if more than 1!! as otherwise it is not factorization
      {
         printf("%c'(", get_pin_name(i));
         print_sop(i_neg);
         printf(")");
      }
      if((i_neg.size() > 0) && (def.size() > 0)) printf(" + ");

      if(def.size() > 0) // Q: only if more than 1!! as otherwise it is not factorization
         print_sop(def);
      printf("\n");

      if(i_pos.size() > 0) fsop5_rel(i_pos, j,k,m,n,-1,space+1);
      if(i_neg.size() > 0) fsop5_rel(i_neg, j,k,m,n,-1,space+1);
      if(def.size() > 0)   fsop5_rel(def, j,k,m,n,-1,space+1);
}

void fsop5(std::vector<int>& v)
{
   int count = 0;
   int min_size = 5*32;
   int v_size = v.size();
// here we have a function
printf("   Info: run 5 factorization... %d products :     ", v.size()); print_sop(v); printf("\n");
// try all 5! = 120 cases, and select (remember) smallest one
// build graph for that case

// TODO: is a/b factor can be better than aa' / b
   for(int i = 0; i < 5; i++)
   {
      for(int j = 0; j < 5; j++)
         for(int k = 0; k < 5; k++)
            for(int m = 0; m < 5; m++)
               for(int n = 0; n < 5; n++)
                  if(i != j && i != k && i != m && i != n &&
                     j != k && j != m && j != n &&
                     k != m && k != n &&
i < j < k < m < n &&
                     m != n) // 120 variants
                  {
                     fsop5_rel(v, i,j,k,m,n,0); // Q: provide order of factors to be used
//                  printf("  %d: %d-%d-%d-%d-%d\n", ++count, i,j,k,m,n);
          // for each vector, try to factor all products that contain active (w/o DC at the moment) literals - list such factors into separate vector
/*
  for(int u = 0; u < v_size; u++)
  {
//     if(!(v[u] & (1<<(i+5)))) if(v[u] & (1<<i)) { printf("catch\n"); } // we can exclude entry from table after it is used for factorization... set flag to restore data without copying arrays...
  }
// Q: how to keep factors!? 5 (4?) vectors sets?
*/
                  }
   }

}
/*
Definition:
The size of a factored form F (denoted ?(F )) is the number of literals in the factored form.

Example: ?((a+b)caВ’) = 4      ?((a+b+cd)(aВ’+bВ’)) = 6

Definition:
A factored form is optimal if no other factored form (for that function) has less literals


every factor saves 1 gate
 ab + ac    3 gates        ab + ac + ad    5 gates    ab + ac + de + df     7 gates    ab + ac + ad + ae   7 gates
 a(b+c)     2 gates        a(b + c + d)    3 gates    a(b + c) + d(e + f)   5 gates    a(b + c + d + e)    4 gates

*/
int main()
{
   std::vector<int> v;

   v.push_back(16+2 + 0x1A0); // a  d   -''-'
   v.push_back(16+1 + 0x1C0); // a   e  -'''-
   v.push_back(8+2  + 0x2A0); //  b d   '-'-'
   v.push_back(8+1  + 0x2C0); //  b  e  '-''-
   v.push_back(4+2  + 0x320); //   cd   ''--'
   v.push_back(4+1  + 0x340); //   c e  ''-'-

   fsop5(v);
   return 0;
}
