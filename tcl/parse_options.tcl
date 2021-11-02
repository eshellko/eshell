proc eshell {args} {
# Argument Usage:
# [-quiet]: 
# [-nolog]: 
# [-top <arg> = <top-level-module>]:
# todo: add necessary arguments, which if missed - call error

   proc lshift {inputlist} {
      upvar $inputlist argv
      set arg  [lindex $argv 0]
      set argv [lrange $argv 1 end]
      return $arg
   }
   puts "   Info: calling eshell '$args'"
# Process command line arguments
   set error 0
   set quiet 0
   set nolog 0
   set top 0
#    set filename {}
#    set cell {}
   set returnString 0
   while {[llength $args]} {
      set name [lshift args]
      switch -regexp -- $name {
         -quiet -
         {^-q(u(i(e(t?)?)?)?)?$} {
            if $quiet!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set quiet 1
         }
         -nolog -
         {^-n(o(l(o(g?)?)?)?)?$} {
            if $nolog!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set nolog 1
         }
         -top -
         {^-t(o(p?)?)?$} {
         # note: -top 0 will be treated as invalid
            if $top!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set top [lshift args] ; # todo: check if no more args
         }
         default {
            if {[string match "-*" $name]} {
               puts "   Error: option '$name' is not valid option."
               incr error
            # Note: defend from empty
            } elseif [string length $name]>0 {
               puts "   Error: option '$name' is not valid option."
               incr error
            }
         }
      }
   }

   if {$error} {
      puts "   Error: $error error(s) happened."
   } else {
      puts "   Info: running tool for design '$top'."
   }
}
# Examples:
#eshell -quiet -nolog -quiet
#eshell -quiet -nolog -unmatch
#eshell -quiet -nolog -top leon4mp
