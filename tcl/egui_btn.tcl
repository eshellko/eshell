# Note: button events defined here
# Buttons handlers
proc EventOnBtnReadVerilog {} {
   global currentDir
   set filename [::tk::dialog::file:: open -defaultextension "*.v" -filetypes {{{Verilog files} {.v}} {{All files} *}} -initialdir ${currentDir} -multiple true -title "Compile Verilog files" ]
   if {[string length $filename]>0} {
       foreach r $filename {
          set last_idx [ string last "/" $r ]
          set dir [ string range $r 0 $last_idx ]
          set currentDir $dir
          read_verilog $r
       }
       vwait mutex
       EventOnBtnReloadEDB
   }
}

proc EventOnBtnReadLiberty {} {
   global currentDir
   set filename [::tk::dialog::file:: open -defaultextension "*.lib" -filetypes {{{Liberty files} {.lib}} {{All files} *}} -initialdir ${currentDir} -multiple true -title "Compile Liberty files" ]
   if {[string length $filename]>0} {
       foreach r $filename {
          set last_idx [ string last "/" $r ]
          set dir [ string range $r 0 $last_idx ]
          set currentDir $dir
          read_lib " $r"
       }
   }
}

proc EventOnBtnBuild {} {
   global ElaboratedDesign
   global last_command
   if {[string length $ElaboratedDesign] == 0 } {
      set last_command "   Error: no design name specified in \"Current design\" field above."
   } else {
      set last_command "Building design $ElaboratedDesign."
      build $ElaboratedDesign
# Note: if build caller, then wokrpsace/read already made (no check for errors)
#.f1.myButtonWorkspace configure -background "light blue"
#.f1.myButtonRead configure -background "light blue"
   }
}

proc EventOnBtnTechmap {} {
   global ElaboratedDesign
   global last_command
   set last_command "Technology Mapping $ElaboratedDesign."
   techmap
#.f1.myButtonOptimize configure -background "light blue"
}

proc EventOnBtnProject {} {
   source tcl/egui_project.tcl
}

proc EventOnBtnIP {} {
# Note: on TYPE field
#       A - list of allowed parameters as provided (one of few cases)
#       B - form to write Verilog compatible parameters (like 32-bit bus value)
#       C - checkbox to specify 1 of 2 chooses
   if [file exist $::env(ESHELL_HOME)/tcl/ip.csv ] {
      set TreeRowsNum 22

      menu .outer.f3.n.ip.tree.popupMenu
      .outer.f3.n.ip.tree.popupMenu configure -tearoff 0
      .outer.f3.n.ip.tree.popupMenu add command -label "Configure & Generate" -command configureIP
      bind .outer.f3.n.ip.tree <Button-3> {tk_popup .outer.f3.n.ip.tree.popupMenu %X %Y}

      global ip_parameters ip_ptypes ip_init_values ip_allowed_values ip_descriptions ip_names ip_vendor ip_version ip_doc
      set category ""
      set fd [open $::env(ESHELL_HOME)/tcl/ip.csv r]
      while {![eof $fd]} {
         set fline [ read $fd ]
         foreach x [ split $fline ";\n"] {
            if [string length $x]>0 {
               # Note: skip commented lines (1-st line must be comment!?)
               if {[string range $x 0 0] eq "#"} {
               # Note: Create CATEGORY to group IPs
               } elseif {[string range $x 0 8] eq "category="} {
                  # Note: extract comment (if present for every subcategory)
                  set category [string range $x 9 end]
                  set cat_name [ split $category "%;\n"]
                  set category [lindex $cat_name 0]
                  .outer.f3.n.ip.tree insert {} end -id $category -text $category -values [list "" "" "" [lindex $cat_name 1] ] -tags "ttkh simple"
               # Note: process IP for specified category
               } else {
                  set id ""
                  set name ""
                  set vendor ""
                  set version ""
                  set proven ""
                  set descr ""
                  set doc ""
                  set cnt 0
                  # Note: extract IP information
                  foreach y [ split $x "~\n"] {
                     if $cnt==0 { set id $y
                        # Note: initialize IP on re-read
                        set ip_parameters($id) {}
                        set ip_ptypes($id) {}
                        set ip_init_values($id) {}
                        set ip_allowed_values($id) {}
                        set ip_descriptions($id) {}
                        set ip_names($id) {}
                        set ip_vendor($id) {}
                        set ip_version($id) {}
                        set ip_doc($id) {}
                     }
                     if $cnt==1 { set name $y; set ip_names($id) $y }
                     if $cnt==2 { set vendor $y; set ip_vendor($id) $y }
                     if $cnt==3 { set version $y; set ip_version($id) $y }
                     if $cnt==4 { set proven $y }
                     if $cnt==5 { set descr $y }
                     if $cnt==6 {
                        foreach t [ split $y "%\n"] {
                           set pid 0
                           foreach r [ split $t ":\n"] {
                              if {$pid==0} { lappend ip_parameters($id) $r
                              } elseif {$pid==1} { lappend ip_ptypes($id) $r
                              } elseif {$pid==2} { lappend ip_init_values($id) $r
                                 # Note: there is no allowed values for B-type parameters
                                 set len [ llength $ip_ptypes($id) ]
                                 set len [expr $len - 1]
                                 set val [ lindex $ip_ptypes($id) $len ]
                                 if {[string eq $val "B"] || [string eq $val "C"]} { incr pid
                                 # Note: empty entry to keep ordered list consistency
                                    lappend ip_allowed_values($id) ""
                                 }
                              } elseif {$pid==3} { lappend ip_allowed_values($id) $r
                              } elseif {$pid==4} { lappend ip_descriptions($id) $r }
                              incr pid
                           }
                        }
                     }
                     if $cnt==7 { set doc $y; set ip_doc($id) $y }
                     incr cnt
                  }
                  .outer.f3.n.ip.tree insert $category end -id $id -text $name -values [list $vendor $version $proven $descr ] -tags "ttk simple"
               }
            }
         }
      }
      close $fd
      .outer.f3.n.ip.tree tag configure ttk  -font efont
      .outer.f3.n.ip.tree tag configure ttkh -font efontbold
   }
   global ip_loaded
   set ip_loaded 1
}

proc EventOnBtnClear {} {
   global ElaboratedDesign
   set ElaboratedDesign {}
   .f2.myComboBox configure -values {}
   clear_db
}

proc EventOnBtnWriteNetlist {} {
   global WorkSpace
   variable filename ${WorkSpace}.v
   catch [ destroy .writer ]
   toplevel .writer
   wm title .writer "Write netlist"
   pack [label .writer.label1 -text "Specify output file name" -font efont ] -fill both -pady 3 -padx 3
   pack [entry .writer.entryWS -text ${WorkSpace}.v -font efont -textvariable filename -width 32] -fill both -pady 3 -padx 3
   pack [button .writer.myButton01 -font efont -width 7 -text "OK"     -command { write $filename ; destroy .writer } ] -padx 3 -pady 3 -side left
   pack [button .writer.myButton02 -font efont -width 7 -text "Cancel" -command "destroy .writer"                     ] -padx 3 -pady 3 -side left

   focus .writer.entryWS
   # Note: ENTER became same as OK
   bind .writer <Return> { write $filename ; destroy .writer }
   bind .writer <Escape> { destroy .writer }
}

proc EventOnBtnReadVCD {} {
   global currentDir
   set filename [::tk::dialog::file:: open -defaultextension "*.vcd" -filetypes {{{Value Change Dump files} {.vcd}} {{All files} *}} -initialdir ${currentDir} -multiple true -title "Read Value Change Dump(VCD) files" ]
   if {[string length $filename]>0} {
      foreach r $filename {
         read_vcd $r
      }
   }
}

proc EventOnBtnReloadEDB {} {
   #set prev_color [.myButton10 cget -background]
   global WorkSpace
   append EdbSpace $WorkSpace ".edb"
   #.myButton10 configure -background red
   ReadEDB $EdbSpace
   #.myButton10 configure -background $prev_color
}

proc EventOnBtnExit {} {
   global io ; # Note: close tool
# TODO: when tool is executing current command, and 'x' button pressed, tool will left active after GUI is closed
#       for such case need to close tool explicitly...
   catch { TOOL_CMD "exit" }
   catch { close $io }
   exit
}

proc EventOnBtnReadSdc {} {
   global currentDir
   set filename [::tk::dialog::file:: open -defaultextension "*.sdc" -filetypes {{{Synopsys Design Constraints files} {.sdc}} {{Tcl files} {.tcl}} {{All files} *}} -initialdir ${currentDir} -multiple true -title "Read Synopsys Design Constraint(SDC) files" ]
   if {[string length $filename]>0} {
      foreach r $filename {
         read_sdc $r
      }
   }
}
#
# Preload Tooltip package
#
source $path/tcl/tooltip.tcl
#
# Note: place relative to rundir where {ip}.csv are located
#
set csv_search_path ./

# Note: combobox used to specify workspace; readonly mode
proc EventOnBtnWorkspace {} {
   global csv_search_path
   global WorkSpace general_purpose_buffer
   set general_purpose_buffer $WorkSpace
   catch [ destroy .workspace ] ; # Note: only one window allowed
   toplevel .workspace
   wm title .workspace "Change workspace name"
# Note: place implementation
   wm geometry .workspace 300x100+120+140
   place [label .workspace.label1 -text "Specify new workspace name" -font efont ] -x 10 -y 5
   place [entry .workspace.entryWS -text $WorkSpace -font efont -textvariable WorkSpace -width [expr 32 - 6]] -x 10 -y 30
   place [button .workspace.myButton01 -font efont -width 7 -text "OK"     -command { wm title . "EHL\ Design\ Browser\ (workspace:\ $WorkSpace)" ; set_workspace $WorkSpace ; destroy .workspace ; read_csv ${csv_search_path}/${WorkSpace}.csv ; } ] -x 30 -y 60
   place [button .workspace.myButton02 -font efont -width 7 -text "Cancel" -command "set workspace $general_purpose_buffer; destroy .workspace" ] -x 130 -y 60
   focus .workspace.entryWS
   # Note: ENTER became same as OK (todo: create proc to use same code for ENTER and OK-button)
   bind .workspace <Return> { wm title . "EHL\ Design\ Browser\ (workspace:\ $WorkSpace)" ; set_workspace $WorkSpace ; destroy .workspace ; read_csv ${csv_search_path}/${WorkSpace}.csv ; }
   bind .workspace <Escape> { set workspace $general_purpose_buffer; destroy .workspace }

   global lista
   set lista [list]
# todo: run on some event - not on creation of window, if new CSV files created while window is open, they will not be displayed
# todo: sort them
   get_csv $csv_search_path *.csv
   # Note: enable ip on current workdir
   setToolTip .workspace.entryWS $lista
}

# todo: it is not an event any more actually
proc SaveHdl filename {
   set fd [open $filename wb]
# todo: do not save additional new line character at the end of file (like "end - 1 chars")
   set data [ .hdleditor.text get 1.0 "end - 1 chars" ]
   puts -nonewline $fd $data
   close $fd
}

proc SaveAndCompileHdl filename {
   SaveHdl $filename
   read_verilog $filename
   vwait mutex ; # Note: wait compilation completed
   EventOnBtnReloadEDB
}

proc ExitHdl {} {
   catch [ destroy .hdleditor ]
}

proc EventOnBtnEditHdl {verilog_keywords is_edit} {
   upvar $verilog_keywords v1364kw

   catch [ destroy .hdleditor ] ; # Note: only one window allowed
   toplevel .hdleditor

   set filename [.outer.f3.n.sources.tree focus]

   wm title .hdleditor "HDL editor ($filename)"
   wm geometry .hdleditor 120x30+20+20

   text .hdleditor.text -width 100 -height 20 -borderwidth 2 -relief raised -setgrid true -yscrollcommand {.hdleditor.scroll set}
   scrollbar .hdleditor.scroll -command {.hdleditor.text yview}
   pack .hdleditor.scroll -side right -fill y
   pack .hdleditor.text -side left -fill both -expand true

   # command menu
   menu .hdleditor.popupMenu
   .hdleditor.popupMenu configure -tearoff 0

   if $is_edit==0 {
   # Note: view with highlight
      #
      # read file in
      #
      set ex [ file exists $filename ]
      set r 1
      set first 1
      if { $ex == 1 } {
         set fd [open $filename rb]
         fconfigure $fd -translation crlf
         set data [read $fd]

         set block_comment 0
         set bc_init "0.0"
         set bc_fini "0.0"

         # Note: read line-by-line and highlight (Note: this is initial only highlight, ideally create function that will be called every time text changed)
         foreach x [ split $data "\n"] {
# todo: drop \r
            if $first==0 {.hdleditor.text insert end "\n"}
            .hdleditor.text insert end "$x"
            set first 0
            set type_of_textR [string range $x 0 1]
            if [string match "//" $type_of_textR] { ; # Note: check for lines started with '//'
               set len [string length $x ]
               set fini "${r}.${len}"
               .hdleditor.text tag add highlightG ${r}.0 $fini
               # Note: #007000 relates to dark green - more readable than just green
               .hdleditor.text tag configure highlightG -foreground "#007000"
            } else {
               #
               # Note: this part highlights line comments in the middle of source code line, like:
               #       wire a; // line for buffering
               #
               set len [string length $x]
               set lc_start $len
               set idx_kw [string first "//" $x]
               set idx_bl [string first "/*" $x]
               set idx_ebl [string first "*/" $x]
               #
               # Note: define which one (line or block) comment is earlier
               # TODO: if inside block, then line comment is ignored -- but can be after leaving block -- *///
               #
               if { $idx_kw!=-1 && $idx_bl!=-1 } {
                  if { $idx_kw < $idx_bl } {
                     set idx_bl -1
                  } else {
                     set idx_kw -1
                  }
               }
               #
               # color line comment
               #
               if $idx_kw!=-1 {
                  set lc_start $idx_kw
                  set init "${r}.${idx_kw}"
                  set fini "${r}.${len}"
                  .hdleditor.text tag add highlightG $init $fini
                  .hdleditor.text tag configure highlightG -foreground "#007000"
               }
               #
               # color block comment
               #
               if { $idx_bl!=-1 && $block_comment==0 } {
                  set bc_init "${r}.${idx_bl}"
                  set block_comment 1
               }
               if { $idx_ebl!=-1 && $block_comment==1 } {
                  set block_comment 0
                  set bc_fini "${r}.${len}" ; # Q: actual value
                  .hdleditor.text tag add highlightY $bc_init $bc_fini
                  .hdleditor.text tag configure highlightY -foreground "#006000"
               }
               #
               # Note: highlight module keywords: todo: use regexp for that
               #
               foreach {tkw len_kw} [array get v1364kw] {
                  set start_pos 0
                  set idx_kw 0
                  while {$idx_kw != -1} {
                     if {$len < $len_kw} { break } ; # Note: do not over short lines
                     set idx_kw [string first $tkw [string range $x $start_pos end]]
                     if $idx_kw!=-1 {
                     # Note: keywords inside line comments filtered away if they located at the right of comment start (w.r.t. $start_pos updated when keyword already present at the same line)
                        if {$idx_kw > [expr $lc_start - $start_pos ] } {
                           set idx_kw -1
                        }
                     }
                     if $idx_kw!=-1 {
                        set tmp [expr $idx_kw + $start_pos]
                        set init "${r}.${tmp}"
                        set tmp [expr $idx_kw + $start_pos + $len_kw]
                        set fini "${r}.${tmp}"
                        # Note: skip highlighting of partially matched words, like "use" from "user"
                        set skip_as_part_of_another_word 0
                        set pre_init [expr $idx_kw + $start_pos - 1]
                        set before [string index $x $pre_init]
                        foreach tch {a b c d e f g h i j k l m n o p q r s t u v w x y z _ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 } {
                           if {$before eq $tch} {
                              set skip_as_part_of_another_word 1
                           }
                        }
                        set post_fini [expr $idx_kw + $start_pos + $len_kw ]
                        set after [string index $x $post_fini]
                        foreach tch {a b c d e f g h i j k l m n o p q r s t u v w x y z _ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 } {
                           if {$after eq $tch} {
                              set skip_as_part_of_another_word 1
                           }
                        }
                        if $skip_as_part_of_another_word==0 {
                           switch -exact $tkw {
                              "`define"              { .hdleditor.text tag add highlightO $init $fini }
                              "`ifdef"               { .hdleditor.text tag add highlightO $init $fini }
                              "`endif"               { .hdleditor.text tag add highlightO $init $fini }
                              "`else"                { .hdleditor.text tag add highlightO $init $fini }
                              "`ifndef"              { .hdleditor.text tag add highlightO $init $fini }
                              "`include"             { .hdleditor.text tag add highlightO $init $fini }
                              "`elsif"               { .hdleditor.text tag add highlightO $init $fini }
                              "`undef"               { .hdleditor.text tag add highlightO $init $fini }
                              "`timescale"           { .hdleditor.text tag add highlightO $init $fini }
                              "`celldefine"          { .hdleditor.text tag add highlightO $init $fini }
                              "`default_nettype"     { .hdleditor.text tag add highlightO $init $fini }
                              "`endcelldefine"       { .hdleditor.text tag add highlightO $init $fini }
                              "`line"                { .hdleditor.text tag add highlightO $init $fini }
                              "`nounconnected_drive" { .hdleditor.text tag add highlightO $init $fini }
                              "`resetall"            { .hdleditor.text tag add highlightO $init $fini }
                              "`unconnected_drive"   { .hdleditor.text tag add highlightO $init $fini }
                              default                { .hdleditor.text tag add highlightB $init $fini }
                           }
                        }
                        .hdleditor.text tag configure highlightB -foreground blue
                        .hdleditor.text tag configure highlightO -foreground orange
                     }
                     set start_pos [expr $start_pos + $idx_kw + $len_kw]
                  }
               }
            }
            incr r
         }
         #
         # Note: color EOF block comment
         #
         if $block_comment==1 {
            set bc_fini "${r}.${len}" ; # Q: set to EOF? Q: 'r-1' ?
            .hdleditor.text tag add highlightY $bc_init $bc_fini
            .hdleditor.text tag configure highlightY -foreground "#006000"
         }
         ###################
         close $fd
      }
      .hdleditor.text configure -state disabled
   } else {
   # Note: edit without highlight
      # read file in
      set ex [ file exists $filename ]
      if { $ex == 1 } {
         set fd [open $filename rb]
         fconfigure $fd -translation crlf
         set data [read $fd ]
         # Note: read single piece of data
         .hdleditor.text insert 1.0 "$data"
         close $fd
      }
      # command menu
      .hdleditor.popupMenu add command -label "Save" -command "SaveHdl $filename"
      .hdleditor.popupMenu add command -label "Save & Compile" -command "SaveAndCompileHdl $filename"
   }
   .hdleditor.popupMenu add command -label "Exit" -command "ExitHdl"
   bind .hdleditor.text <Button-3> {tk_popup .hdleditor.popupMenu %X %Y}
}

# Note: executes custom.tcl user script to create its' own GUI table to work with custom EDA Flow
proc EventOnBtnCustom {} {
   if {[info exists ::env(ESHELL_HOME)]} {
      set custom_file_path $::env(ESHELL_HOME)/tcl/custom.tcl
      if [file exists $custom_file_path] {
         source $custom_file_path
      }
   }
}

set BT_WINDOW .bt_win.outer. ; # Note: defined in global namespace - outer added to match bt.tcl suffix
set BT_WINDOW_GUI .bt_win ; # Note: defined in global namespace
# Note: tool should use same tasks.csv, as bt.tcl placed into EHL repository
proc EventOnBtnBugTracker {} {
   global BT_WINDOW_GUI
   global path
   global BT_WINDOW
   set BT_WINDOW .bt_win.outer. ; # Note: defined in global namespace - outer added to match bt.tcl suffix
   set BT_WINDOW_GUI .bt_win ; # Note: defined in global namespace
   catch [ destroy $BT_WINDOW_GUI ]
   source $path/ehl/share/src/tcl/bt.tcl
}
