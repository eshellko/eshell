proc eshell {} {
   global argv
   set args $argv
   global tool_arguments
   global tool_name
# Argument Usage:
# [-quiet]:
# [-noinit]:
# [-nolog]:
# [-tcl]:
# [-top <arg> = <top-level-module>]:

#puts "   Info: calling eshell '$args'"
# Process command line arguments
   set error 0
   set quiet 0
   set nolog 0
   set noinit 0
   set tcl 0
   set nolog 0
   set top 0
   set b32 0
   set b64 0
#    set filename {}
#    set cell {}
   set returnString 0

   while {[llength $args]} {
      set name [lindex $args 0]
      set args [lrange $args 1 end]
      switch -regexp -- $name {
         -b32 -
         {^-3(2?)?$} {
            if $b32!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set tool_name "i686.exe"
            set b32 1
         }
         -b64 -
         {^-6(4?)?$} {
            if $b32!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set b64 1
         }
         -quiet -
         {^-q(u(i(e(t?)?)?)?)?$} {
            if $quiet!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set quiet 1
            lappend tool_arguments "-quiet"
         }
         -noinit -
         {^-n(o(i(n(i(t?)?)?)?)?)?$} {
            if $noinit!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set noinit 1
            lappend tool_arguments "-noinit"
         }
         -nolog -
         {^-n(o(l(o(g?)?)?)?)?$} {
            if $nolog!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set nolog 1
            lappend tool_arguments "-nolog"
         }
         -tcl -
         {^-t(c(l?)?)?$} {
            if $tcl!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set tcl 1
            lappend tool_arguments "-tcl"
         }
         -top -
         {^-t(o(p?)?)?$} {
         # note: -top 0 will be treated as invalid
            if $top!=0 {
               puts "   Error: option '$name' used more than once."
               incr error
            }
            set top [lshift args] ; # TODO: check if no more args
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
   # Note: check for necessary argument
   if {$tcl==0} {
      puts "   Error: no '-tcl' argument provided."
      set error 1
   }

   if {$error} {
      puts "   Error: $error error(s) happened."
      exit 1
   } ; # else {
#      puts "   Info: running tool for design '$top'."
#   }
}
