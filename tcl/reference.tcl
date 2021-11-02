proc drag.canvas.item {canWin item newX newY} {
   set xDiff [expr {$newX - $::x}]
   set yDiff [expr {$newY - $::y}]

   set ::x $newX
   set ::y $newY

   $canWin move $item $xDiff $yDiff
}

proc ReferenceMethodology {} {
   set stages [ list \
              [ list compile   " Compile   "  90  50 efont green  black "!!!" ] \
              [ list lint      " Lint      "  90  90 efont green  black "!!!" ] \
              [ list elaborate " Elaborate "  90 130 efont gray   black "!!!" ] \
              [ list optimize  " Optimize  "  90 170 efont green  black "!!!" ] \
              [ list write     " Write     "  90 210 efont green  black "!!!" ] \
   ]

   catch [ destroy .referenceMethodology ] ; # Note: only one window allowed
   toplevel .referenceMethodology
   wm title .referenceMethodology "Reference Methodology"
   wm geometry .referenceMethodology 300x300+0+0
   wm minsize .referenceMethodology 300 300
   wm maxsize .referenceMethodology 300 300

   pack [canvas .referenceMethodology.c] -expand 1 -fill both

   set len [llength $stages]
   for {set ih 0} {$ih<$len} {incr ih} {
      set val [lindex $stages $ih]
      set i [lindex $val 0]
      set j [lindex $val 1]
      set k [lindex $val 2]
      set m [lindex $val 3]
      set f [lindex $val 4]
      set b [lindex $val 5]
      set c [lindex $val 6]
      set t [lindex $val 7]

      button .referenceMethodology.$i -text $j -font $f -bg $b -fg $c
      set id [.referenceMethodology.c create window $k $m -window .referenceMethodology.$i]

      bind .referenceMethodology.$i <3> {
         set ::x %X
         set ::y %Y
      }

      bind .referenceMethodology.$i <B3-Motion> [list drag.canvas.item .referenceMethodology.c $id %X %Y]
      setToolTip .referenceMethodology.$i $t ; # todo: another text
   }
}
