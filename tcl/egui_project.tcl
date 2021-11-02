if {[info exists email]} {
   set WINDOW .proj
   toplevel $WINDOW
} else {
   set WINDOW .
}

wm title $WINDOW "Project Browser"
wm iconname $WINDOW "tree"

wm attributes $WINDOW -fullscreen 1

if {$WINDOW eq ".proj"} {
   set WINDOW .proj.
}




# findFiles
# basedir - the directory to start looking in
# pattern - A pattern, as defined by the glob command, that the files must match
proc findFiles { basedir pattern } {
global WINDOW

    # Fix the directory name, this ensures the directory name is in the
    # native format for the platform and contains a final directory separator
    set basedir [string trimright [file join [file normalize $basedir] { }]]
    set fileList {}

    # Look in the current directory for matching files, -type {f r}
    # means ony readable normal files are looked at, -nocomplain stops
    # an error being thrown if the returned list is empty
    foreach fileName [glob -nocomplain -type {f r} -path $basedir $pattern] {
       if { [string last "src/rtl" $fileName]!=-1} {
# todo: open each file and get line of code...
#          ${WINDOW}log1 insert {} end -text "Read file $fileName.";

         set ex [ file exists $fileName ]
         if { $ex == 1 } {
            set fd [open $fileName r]
               while {![eof $fd]} {
                  set fline [ read $fd ]
                  set code 0
                  set line 1
                  foreach x [ split $fline "\n\r"] {
# todo: check line numbers
# todo: report if no standard header found (fully or partially)
                     if { [string last "Design:" $x]!=-1} {
#                        ${WINDOW}log1 insert {} end -text "$x.";
                        if $line==1 { set code [expr $code | 0x1] }
# set offset [ string first ":" $x ]
# set ggg [     string trimleft [string range $x [expr $offset+1] end ] " "    ]
# ${WINDOW}log1 insert {} end -text "$ggg !!!";
                     }
                     if { [string last "Revision:" $x]!=-1} {
#                        ${WINDOW}log1 insert {} end -text "$x.";
                        if $line==2 { set code [expr $code | 0x2] }
                     }
                     if { [string last "Date:" $x]!=-1} {
#                        ${WINDOW}log1 insert {} end -text "$x.";
                        if $line==3 { set code [expr $code | 0x4] }
                     }
                     if { [string last "Company:" $x]!=-1} {
#                        ${WINDOW}log1 insert {} end -text "$x.";
                        if $line==4 { set code [expr $code | 0x8] }
                     }
                     if { [string last "Designer:" $x]!=-1} {
#                        ${WINDOW}log1 insert {} end -text "$x.";
                        if $line==5 { set code [expr $code | 0x10] }
                     }
#                     if { [string last "Description:" $x]!=-1} {
##                        ${WINDOW}log1 insert {} end -text "$x.";
#                        if $line==6 { set code [expr $code | 0x20] }
#                     }
                     if { [string last "Last modified by:" $x]!=-1} {
#                        ${WINDOW}log1 insert {} end -text "$x.";
                        if $line==6 { set code [expr $code | 0x20] }
                     }
                     incr line
                  }
                  if $code!=0x3f {
                     ${WINDOW}log1 insert {} end -text "Error: no standard header present for ${fileName}(code: $code).";
                  } else {
#                      ${WINDOW}log1 insert {} end -text "Read file $fileName.";
                  }
               }
            close $fd
         }
      }

#        lappend fileList $fileName
    }

    # Now look for any sub directories in the current directory
    foreach dirName [glob -nocomplain -type {d  r} -path $basedir *] {
        # Recursively call the routine on the sub directory and append any
        # new files to the results
        set subDirList [findFiles $dirName $pattern]
#        if { [llength $subDirList] > 0 } {
#            foreach subDirFile $subDirList {
#                lappend fileList $subDirFile
#            }
#        }
    }
#    return $fileList
 }






## Code to populate the roots of the tree (can be more than one on Windows)
proc populateRoots {tree} {
#    foreach dir [lsort -dictionary [file volumes]] {
#}
# Note: specify starting from 1 level upper than project directory (do-while vs. while)
# todo: set root directory when project created... open project file on startup (or by request - load project)
#foreach dir [lsort -dictionary [file dirname "."]]
   foreach dir [lsort -dictionary [file dirname "/home/guest/projects/tool/ehl/*"]] {
      populateTree $tree [$tree insert {} end -text $dir -values [list $dir directory]]
   }
}

## Code to populate a node of the tree
proc populateTree {tree node} {
global WINDOW
   if {[$tree set $node type] ne "directory"} {
      return
   }
   set path [$tree set $node fullpath]
   $tree delete [$tree children $node]
# 1. process directories
   foreach f [lsort -dictionary [glob -nocomplain -dir $path *]] {
      set type [file type $f]
      if {$type eq "directory"} {
         set id [$tree insert $node end -id [file rootname $f] -text [file tail $f] -values [list $f $type] ]
         ## Make it so that this node is openable
         $tree insert $id 0 -text dummy ;# a dummy
         $tree item $id -text [file tail $f]/
#         $tree item $id -text [file rootname $f]/
# todo: recursively open all directories ; todo: get ID of directory item in list
#populateTree ${tree} ${tree}.$id ; #[file rootname $f]
#populateTree ${tree} [ ${tree} focus $id ] ; #[file rootname $f]
#populateTree ${tree} [file rootname $f]
      }
   }
# 2. process files with mask ... todo: also add another extensions
   foreach f [lsort -dictionary [glob -nocomplain -dir $path *.v]] {
      set type [file type $f]
      if {$type eq "file"} {
         set id [$tree insert $node end -text [file tail $f] -values [list $f $type]]
         set size [file size $f]
         ## Format the file size nicely
         if {$size >= 1024*1024*1024} {
            set size [format %.1f\ GB [expr {$size/1024/1024/1024.}]]
         } elseif {$size >= 1024*1024} {
            set size [format %.1f\ MB [expr {$size/1024/1024.}]]
         } elseif {$size >= 1024} {
            set size [format %.1f\ kB [expr {$size/1024.}]]
         } else {
            append size " bytes"
         }
         $tree set $id size $size
# todo: open file and check standard header present, read it to define version, split up to ':' to disable text
#${WINDOW}log1.[ ${WINDOW}log1 insert {} end -text "Read file $f." ] focus; # -tags "-font efont"
${WINDOW}log1 insert {} end -text "Read file $f."; # -tags "-font efont"
      }
   }
   # Stop this code from rerunning on the current node
   $tree set $node type processedDirectory
}

## Create the tree and set it up
ttk::treeview ${WINDOW}tree_prj -columns {fullpath type size} -displaycolumns {size} -yscroll "${WINDOW}vsb set" -xscroll "${WINDOW}hsb set"
ttk::scrollbar ${WINDOW}vsb -orient vertical -command "${WINDOW}tree_prj yview"
ttk::scrollbar ${WINDOW}hsb -orient horizontal -command "${WINDOW}tree_prj xview"
${WINDOW}tree_prj heading \#0 -text "Directory Structure"
${WINDOW}tree_prj heading size -text "File Size"
${WINDOW}tree_prj column size -stretch 0 -width 70
${WINDOW}tree_prj column \#0 -stretch 0 -width 270
populateRoots ${WINDOW}tree_prj
bind ${WINDOW}tree_prj <<TreeviewOpen>> {populateTree %W [%W focus]}

## Arrange the tree and its scrollbars in the toplevel
lower [ttk::frame ${WINDOW}dummy]
pack ${WINDOW}dummy -fill both -expand 1
grid ${WINDOW}tree_prj ${WINDOW}vsb -sticky nsew -in ${WINDOW}dummy
grid ${WINDOW}hsb -sticky nsew -in ${WINDOW}dummy
grid columnconfigure ${WINDOW}dummy 0 -weight 1
grid rowconfigure ${WINDOW}dummy 0 -weight 1

place [ ttk::treeview ${WINDOW}log1 -height 25 ] -x 170 -y 110 -width 850
${WINDOW}log1 heading #0 -text "Message log" -anchor w
#${WINDOW}log1 insert {} end -id Infos -text "Infos" -open true ; #-tags "-font efont"

# Examples:
# findFiles "/home/prj/ehl/uart/" "*.v"
