# Note: the intention of this file is to check commented header of Verilog source files (RTL)
#       as specified by DO-254
#       currently this file checks specified files for existence of the following header (example):
#// Design:           UART with APB host interface
#// Revision:         1.2
#// Date:             2014-10-17
#// Company:          Eshell
#// Designer:         A.Kornukhin (kornukhin@mail.ru)
#// Last modified by: 1.1 2013-10-31 A.Kornukhin, added TICKS_TO_BIT
# limitations:
#  only single line tags allowed
#  no check for tags content (description)
# to start with specified directory execute following in TCL shell:
#  checkHeader "E:/projects/base/" "*.v"

proc firstNotSpaceChar { str pos } {
   set ipos $pos
   while {[string index $str $ipos] eq " "} {
      incr ipos
   }
   return $ipos
}

proc checkFileHeader { fileName eshell_gui } {
   set ex [ file exists $fileName ]
   if { $ex == 1 } {
      set fd [open $fileName r]
      set code 0
      while {![eof $fd]} {
         set fline [ read $fd ]
         set line 1
         set DESIGN ""
         set REVISION ""
         set DATE ""
         set COMPANY ""
         set DESIGNER ""  ; # todo: check against list of authorized persons
         set MODIFIED ""
#            set DESCRIPTION ""
         foreach x [ split $fline "\n\r"] {
# todo: check line numbers
            if { [string last "Design:" $x]!=-1}           { if $line==1 { set code [expr $code | 0x1] } ; set ipos [firstNotSpaceChar $x 10] ; set DESIGN [string range $x $ipos end] ;  }
            if { [string last "Revision:" $x]!=-1}         { if $line==2 { set code [expr $code | 0x2] } ; set REVISION [string range $x [expr [string last " " $x]+1] end] ; }
            if { [string last "Date:" $x]!=-1}             { if $line==3 { set code [expr $code | 0x4] } ; set DATE [string range $x [expr [string last " " $x]+1] end] ;  }
            if { [string last "Company:" $x]!=-1}          { if $line==4 { set code [expr $code | 0x8] } ; set COMPANY [string range $x [expr [string last " " $x]+1] end] ;  }
            if { [string last "Designer:" $x]!=-1}         { if $line==5 { set code [expr $code | 0x10] } ; set DESIGNER [string range $x [expr [string last " " $x]+1] end] ;  }
            if { [string last "Last modified by:" $x]!=-1} { if $line==6 { set code [expr $code | 0x20] } ; set MODIFIED [string range $x [expr [string last " " $x]+1] end] ;  }
#                     if { [string last "Description:" $x]!=-1} { if $line==6 { set code [expr $code | 0x20] } }
            incr line
            if $line>7 { break } ; # Note: break to not parse the whole file...
         }
      }
      close $fd
      if $eshell_gui==1 {
         set last_idx [ string last "/" $fileName ]
         set wout_dir [ string range $fileName [expr $last_idx+1] end ]
         set timeline [file mtime $fileName]
         set timeline [clock format $timeline -format {%Y-%m-%d %H:%M:%S} ]
         if $code!=0x3f {
            .outer.f3.tree insert {} end -id $fileName -text "$wout_dir ($timeline)" -tags "ttk simple" -values [list "-" "-" "-" "No standard header present ($code)"]
         } else {
            .outer.f3.tree insert {} end -id $fileName -text "$wout_dir ($timeline)" -tags "ttk simple" -values [list $COMPANY $REVISION $DATE $DESIGN]
         }
         .outer.f3.tree tag configure ttk -font efont
      } else {
         if $code!=0x3f { puts "Error: no standard header present for ${fileName}(code: $code)." }
      }
   } else {
      global last_command
      set last_command "Can't open file $fileName."
   }
}

# basedir: the directory to start looking in
# pattern: a pattern, as defined by the glob command, that the files must match
proc checkHeader { basedir pattern } {
   global eshell_gui
   if ![info exist eshell_gui] { ; # Note: if no such variable (standalone run), then create one for console mode
      set eshell_gui 0
   }
   # Fix the directory name, this ensures the directory name is in the
   # native format for the platform and contains a final directory separator
   set basedir [string trimright [file join [file normalize $basedir] { }]]

   # Look in the current directory for matching files, -type {f r}
   # means ony readable normal files are looked at, -nocomplain stops
   # an error being thrown if the returned list is empty
   foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
      set ex [ file exists $fileName ]
      if { $ex == 1 } {
         checkFileHeader $fileName $eshell_gui
      }
   }
   if $eshell_gui==0 {
      # Now look for any sub directories in the current directory
      foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
         # Recursively call the routine on the sub directory and append any
         # new files to the results
         set subDirList [checkHeader $dirName $pattern]
      }
   }
}

if { $::argc > 0 } {
   foreach arg $::argv {
      checkHeader $arg *.v
   }
}
