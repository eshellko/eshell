# Create initial layout using frames
#  f1 - left columns with control buttons
#  f2 - upper line with control elements
#  f3 - design content list
#  f4 - log window
#  f5 - additional settings window
#  f6 - bottom frame with command line, and status label
frame .f1 -background grey85
frame .f2 -background grey85
#frame .f3
#frame .f4
frame .f5 -background grey85
frame .f6 -background grey85

######################################
#    #            f2            .    #
#    ###########################.    #
#    #                          .    #
#    #            f3            .    #
# f1 #                          .    #
#    ###########################. f5 #
#    #                          .    #
#    #            f4            .    #
#    #                          .    #
################################.    #
#               f6              .    #
######################################

pack .f6 -side bottom -fill x
pack .f1 -side left -fill y
pack .f2 -side top -fill x
pack [ ttk::panedwindow .outer -orient horizontal ] -fill both -expand y
.outer add [ttk::panedwindow .outer.inRight -orient vertical]
.outer.inRight add [frame .outer.f3 -background grey85]
.outer.inRight add [frame .outer.f4 -background grey85]

pack .f5 -side right -fill both -after .f1
pack forget .f5

# Note: progress bar, which turned on when process launched
ttk::progressbar .f1.progress -mode indeterminate -maximum 100
pack .f1.progress -fill both -expand 0
############################
#
# Buttons
#
############################
# Note: buttons created before initial tool setup made, which will call start_cmd/stop_cmd and thus modify buttons settings
#       so they configured once more
array set button_cfg [ list \
   0  [ list 0 "Workspace"     EventOnBtnWorkspace    normal ] \
   1  [ list 1 "Read"          {tk_popup .pMenuRead [expr [winfo rootx .f1.myButtonRead]+[winfo width .f1.myButtonRead]] [expr [winfo rooty .f1.myButtonRead]]}               disabled \
                               Verilog EventOnBtnReadVerilog \
                               Liberty EventOnBtnReadLiberty \
                               SDC     EventOnBtnReadSdc \
                               VCD     EventOnBtnReadVCD \
                   ] \
   2  [ list 0 "Build"         EventOnBtnBuild        disabled ] \
   3  [ list 1 "Optimize"      {tk_popup .pMenuOptimize [expr [winfo rootx .f1.myButtonOptimize]+[winfo width .f1.myButtonOptimize]] [expr [winfo rooty .f1.myButtonOptimize]]}       disabled \
                               Area           "opt -area" \
                               Timing         "opt -time" \
                               Logic          "opt" \
                               Ungroup        "ungroup" \
                               Exit           "" \
                   ] \
   4  [ list 0 "Techmap"       EventOnBtnTechmap      disabled ] \
   5  [ list 1 "Report"        {tk_popup .pMenuReport [expr [winfo rootx .f1.myButtonReport]+[winfo width .f1.myButtonReport]] [expr [winfo rooty .f1.myButtonReport]]}       disabled \
                               Hierarchy      "report_hierarchy -resources -depth 4" \
                               BlackBox       "report_blackbox" \
                               Design         "report_design" \
                               Library        "report_libs" \
                               Lint           "report_lint -clear" \
                               Settings       "report_settings" \
                               Timing         "report_timing" \
                               Uninitialized  "report_uninitialized" \
                               VCD            "report_vcd" \
                               Workspace      "report_workspace" \
                               "D-Flops"      "report_d_flops" \
                               Exit           "" \
                   ] \
   6  [ list 0 "Write netlist" EventOnBtnWriteNetlist disabled ] \
   7  [ list 0 "Custom"        EventOnBtnCustom       normal ] \
   8  [ list 0 "Clear"         EventOnBtnClear        disabled ] \
   9  [ list 0 "Bug Tracker"   EventOnBtnBugTracker   normal ] \
   10 [ list 0 "<-"            ExtendSize             normal ] \
   11 [ list 0 "Exit"          EventOnBtnExit         normal ] \
]

# Note: use 'convert omg.png img.gif'
#image create photo .ip -format gif -file $::env(ESHELL_HOME)/tcl/ip.gif

set anum [array size button_cfg]
for {set i 0} {$i < $anum} {incr i} {
   set btn_menu [lindex $button_cfg($i) 0]
   set btn_name [lindex $button_cfg($i) 1]
   set btn_hndl [lindex $button_cfg($i) 2]
# create button
#   if [string eq $btn_name "IP"] {
#      pack [button .f1.myButton$btn_name -relief groove -font efont -compound left -image .ip -text $btn_name -command $btn_hndl ] -side top -pady 1 -padx 2
#   } else {
      pack [button .f1.myButton$btn_name -relief groove -font efont -width 12 -text $btn_name -command $btn_hndl -anchor w ] -side top -pady 1 -padx 2
#   }
   .f1.myButton$btn_name configure -background          [.f1 cget -background]
   .f1.myButton$btn_name configure -activebackground    "light green" ; # Note: highlight button when mouse is on
   .f1.myButton$btn_name configure -foreground          black
   .f1.myButton$btn_name configure -activeforeground    black
   .f1.myButton$btn_name configure -disabledforeground  grey85
   .f1.myButton$btn_name configure -highlightcolor      black
   .f1.myButton$btn_name configure -highlightbackground black
   .f1.myButton$btn_name configure -highlightthickness 1

# create menu if required
   if $btn_menu==1 {
      set menu_name ".pMenu${btn_name}"
      set men [menu $menu_name]
      $menu_name configure -tearoff 0
      set len [llength $button_cfg($i)]
      set len [expr $len - 4]
      set len [expr $len / 2]
      for {set j 0} {$j < $len } { incr j} {
         set men_text [lindex $button_cfg($i) [expr $j * 2 + 4]]
         set men_hndl [lindex $button_cfg($i) [expr $j * 2 + 5]]
         $menu_name add command -label $men_text -command $men_hndl -font efont
      }
   }
}
############################
#
# Trees
# - sources
# - project
# - IPs
#
############################
set TreeRowsNum 8

pack [::ttk::notebook .outer.f3.n] -fill both -expand true -side bottom

set views {sources project ip}
set heads { {Vendor Version Date Description Name} {Description File} {Vendor Version Honor Description Name} }
set aligns { {80 70 120 0 0} {0 0} {80 70 120 0 0} }

foreach v $views h $heads a $aligns {
   ::ttk::entry .outer.f3.n.$v
   .outer.f3.n add .outer.f3.n.$v -text $v
   set numb [llength $h] ; # Number of columns
   set columns ""
   set displaycolumns ""
   for {set i 0} {$i < [expr $numb - 1]} {incr i} {
      set columns "$columns [lindex $h $i]"
      set displaycolumns "[lindex $h $i] $displaycolumns"
   }

   pack [ ttk::treeview .outer.f3.n.${v}.tree -columns $columns -displaycolumns $displaycolumns -height $TreeRowsNum ] -side left -expand y -fill both
   for {set i 0} {$i < [expr $numb - 1]} {incr i} {
      set t "[lindex $h $i]"
      .outer.f3.n.${v}.tree heading $t -text $t -anchor w
   }
   set t "[lindex $h [expr $numb-1]]"
   .outer.f3.n.${v}.tree heading #0 -text $t -anchor w

   set tabsize [winfo screenmmwidth .outer.f3.n.${v}.tree ]
   set overal 0
   for {set i [expr $numb - 3]} {$i >= 0} {set i [expr $i - 1]} {
      set overal [expr $overal + [lindex $a $i]]
   }

   .outer.f3.n.${v}.tree column #0 -width [expr ($tabsize - $overal) / 2]
   .outer.f3.n.${v}.tree column [lindex $h [expr $numb - 2]] -width [expr ($tabsize - $overal) / 2]

   for {set i [expr $numb - 3]} {$i >= 0} {set i [expr $i - 1]} {
      .outer.f3.n.${v}.tree column [lindex $h $i] -width [lindex $a $i] -stretch no
   }
   # scrollbar
   pack [ scrollbar .outer.f3.n.${v}.sby -orient vert -width 12 ] -side right -fill y
   .outer.f3.n.${v}.tree conf -yscrollcommand ".outer.f3.n.${v}.sby set"
   .outer.f3.n.${v}.sby conf -command ".outer.f3.n.${v}.tree yview"
}

# Note: load IP catalog after IP tab selected for a first time
bind .outer.f3.n <<NotebookTabChanged>> tabChanged
proc tabChanged {} {
   if {[.outer.f3.n select] eq ".outer.f3.n.ip"} {
      if {$::ip_loaded==0} {
         EventOnBtnIP
      }
   }
}

.outer.f3.n.project.tree insert {} end -id top -text "top" -tags "ttk simple" -values [list "-"]
.outer.f3.n.project.tree insert {} end -id lib -text "lib" -tags "ttk simple" -values [list "-"]
.outer.f3.n.project.tree insert {} end -id sgdc -text "sgdc" -tags "ttk simple" -values [list "-"]
.outer.f3.n.project.tree insert {} end -id bb -text "bb" -tags "ttk simple" -values [list "-"]
.outer.f3.n.project.tree insert {} end -id parameter -text "parameter" -tags "ttk simple" -values [list "-"]
.outer.f3.n.project.tree insert {} end -id define -text "define" -tags "ttk simple" -values [list "-"]
.outer.f3.n.project.tree insert {} end -id incdir -text "incdir" -tags "ttk simple" -values [list "-"]
############################
#
# Edit HDL
#
############################
menu .popupMenu
.popupMenu configure -tearoff 0
.popupMenu add command -label "Edit HDL" -command "EventOnBtnEditHdl"
.popupMenu add command -label "View HDL" -command "EventOnBtnViewHdl"
#proc EventOnBtnCommit {} {
#   set filename [.outer.f3.tree focus]
#   puts "[exec git status $filename]"
#}
#.popupMenu add command -label "Commit" -command "EventOnBtnCommit"
.popupMenu add command -label "Compile" -command "EventOnBtnCompile"
proc EventOnBtnCompile {} {
   set filename [.outer.f3.n.sources.tree focus]
   read_verilog $filename
   vwait mutex
   EventOnBtnReloadEDB
}
.popupMenu add command -label "Compile All" -command "EventOnBtnCompileAll" ; # -state disable ; # todo: add valid file name, not 'id'
 proc EventOnBtnCompileAll {} {
   set filetop [.outer.f3.n.sources.tree children {}]
# TODO: when tool exited during read - stop reading next files... and do not halt
   foreach r $filetop {
      read_verilog $r
      vwait mutex
   }
   EventOnBtnReloadEDB
}
#.popupMenu add command -label "Read instruction" -command bell
# Note: Button-1/2/3 from left to right... when mouse doesn't have scroll wheel, number can be different (touch pad doesn't think so)?
#bind .outer.f3.tree <Double-Button-1> {tk_popup .popupMenu %X %Y}
#bind .outer.f3.tree <Button-2> {tk_popup .popupMenu %X %Y}
bind .outer.f3.n.sources.tree <Button-3> {tk_popup .popupMenu %X %Y}
############################
#
# Log
#
############################
pack [ text .outer.f4.text -state normal -height 10 -font efont -wrap char -background white ] -side left -expand y -fill both
.outer.f4.text insert end "Welcome to EHL $sw_version.\n"
.outer.f4.text see end
.outer.f4.text configure -state disabled
menu .popupMenu2
.popupMenu2 configure -tearoff 0
.popupMenu2 add command -label "Clear" -command "EventOnMenuClear"
proc EventOnMenuClear {} {
   .outer.f4.text configure -state normal
   .outer.f4.text delete 1.0 end
   .outer.f4.text configure -state disable
}
bind .outer.f4.text <Button-3> {tk_popup .popupMenu2 %X %Y}
# scrollbar
pack [ scrollbar .outer.f4.sby -orient vert -width 12 ] -side right -fill y
.outer.f4.text conf -yscrollcommand {.outer.f4.sby set}
.outer.f4.sby conf -command {.outer.f4.text yview}
############################
#
# ComboBox
#
############################
pack [button  .f2.myMessage -font efont -relief flat -width 9 -text "Current\ndesign" -command EventOnBtnReloadEDB -anchor c -font efont -background grey85 ] -side left -padx 4
setToolTip .f2.myMessage "Push to reload EDB"
append EdbSpace $WorkSpace ".edb"
# Note: -height set in terms of text lines
pack [ttk::combobox .f2.myComboBox -textvariable ElaboratedDesign  -state readonly -font efont -height 20 ] -side left -padx 4 ; # todo: place predefined packaged designs from ehl in list
############################
#
# Radiobutton
#
############################
pack [label .f2.label1 -text "Message level" -font efont -background grey85] -side top -after .f2.myComboBox -anchor w -padx 30 -pady 4
pack [radiobutton .f2.errorBtn -text "Error"   -variable mesLev -command "message ERROR" -value "ERROR" -font efont -background grey85] -side left
pack [radiobutton .f2.warnBtn  -text "Warning" -variable mesLev -command "message WARN"  -value "WARN"  -font efont -background grey85] -side left
pack [radiobutton .f2.noteBtn  -text "Note"    -variable mesLev -command "message NOTE"  -value "NOTE"  -font efont -background grey85] -side left
.f2.errorBtn select
############################
#
# Checkbutton
#
############################
# Note: set default before trace, to avoid not necessary commands to eshell (on the other hand it will synchronize gui and console)
proc proc_break { var e op rr } {
   global eshell_tool
   if $eshell_tool==1 {
      start_cmd
      global $e
      if $$e==1 {
         TOOL_CMD "set $e"
      } else {
         TOOL_CMD "unset $e"
      }
   }
}

proc print_settings {arr} {
   upvar $arr a
   set anum [array size a]
   for {set i 0} {$i < $anum} {incr i} {
      # Note: made variable global to refer by out-of-proc functions
      set ::cfg_name [lindex $a($i) 0]
      set cfg_text [lindex $a($i) 1]
      set cfg_enbl [lindex $a($i) 2]
      set cfg_tips [lindex $a($i) 3]

      variable $::cfg_name $cfg_enbl
      trace variable ::$::cfg_name wu {proc_break $$::cfg_name}
      pack [checkbutton .f5.$::cfg_name -font efont -text $cfg_text -variable $::cfg_name -background grey85 ] -side top -anchor w
      setToolTip .f5.$::cfg_name $cfg_tips
   }
}

# Note: texts are same as  in help.cpp
array set vlog_cfg [ list \
   0  [ list break_vlog_on_undirected_port               "Break Vlog On Undirected Port"              1 "When set break the compilation if any port has no direction." ] \
   1  [ list break_vlog_on_tri01                         "Break Vlog On Tri Port"                     1 "When set treat tri0/tri1 port types as wires; otherwise they are not supported. This nets should have pull-up/pull-down which is not supported by tool." ] \
   2  [ list break_vlog_on_verilog_xl_compiler_directive "Break Vlog On VerilogXL Compiler Directive" 1 "When set break the compilation if Verilog-XL directive found. Otherwise directive (one of the suppress_faults, nosuppress_faults, enable_portfaults, disable_portfaults, delay_mode_path, delay_mode_unit, delay_mode_zero, delay_mode_distributed) ignored." ] \
   3  [ list break_vlog_on_zero_width_constants          "Break Vlog On Zero Width Constants"         1 "When set break the compilation on constants with zero width. In other case treat them as 1'b0." ] \
   4  [ list break_vlog_on_systemverilog                 "Break Vlog on SystemVerilog"                1 "When set reports an error in case of SystemVerilog construct detected in source code." ] \
]

array set elab_cfg [ list \
   0  [ list break_elab_on_extra_parameter       "Break Elab On Extra Parameter"       1 "When set break the elaboration if instance has connected parameters which are not present in instantiated module." ] \
   1  [ list break_elab_on_extra_port            "Break Elab On Extra Port"            1 "When set break the elaboration if instance has connected ports which are not present in instantiated module." ] \
   2  [ list break_elab_on_unreferenced_instance "Break Elab On Unreferenced Instance" 1 "When set break elaboration if module referenced but not found in library." ] \
   3  [ list break_elab_on_missed_timescale      "Break Elab On Missed Timescale"      1 "When set break the elaboration when some of the modules has timescale specified but other do not." ] \
]

array set tool_cfg [ list \
   0  [ list allow_incremental_compilation          "Allow Incremental Compilation"          0 "When set skips compilation of modules that were not modified since last compilation (do not check for included modules)." ] \
   1  [ list detect_xs_in_unary_plus                "Detect Xs In Unary Plus"                1 "Verilog standard doesn't clearly explain how to implement unary plus operator:\n(1) IEEE 1364-2005 5.1.5:\nFor the arithmetic operators, if any operand bit value is the unknown value x or the high-impedance value z, then the entire result should be x.\n(2) Table 5-7:\nUnary plus m (same as m).\nWhen detect_xs_in_unary_plus set - (1) implemented, otherwise (2).\nDefault is (1) should be treated as 'value if no Xs' as otherwise unary plus doesn't have any meaning." ] \
   2  [ list append_parameters_to_build_module_name "Append Parameters To Build Module Name" 0 "Append parameter name and value to elaborated module name. This allow find out what value were used to elaborate module. This option not affected top level module." ] \
   3  [ list use_built_in_edb                       "Use EDB"                                0 "When set EHL modules from built-in tool's library when there is no user provided modules." ] \
]

pack [label .f5.label4 -text "COMPILATION" -font efontbold -background grey85 ] -side top
print_settings vlog_cfg
pack [label .f5.label5 -text "ELABORATION" -font efontbold -background grey85 ] -side top
print_settings elab_cfg
pack [label .f5.label6 -text "SETTINGS" -font efontbold -background grey85 ] -side top
print_settings tool_cfg
pack [label .f5.label7 -text "GUI" -font efontbold -background grey85 ] -side top

#set tree_format 0 ; # Note: file tree format: 0 - flat list; 1 - hierarhicla path-based tree
variable tree_format 0 ; # Note: file tree format: 0 - flat list; 1 - hierarhicla path-based tree
#       variable $::cfg_name $cfg_enbl
#       trace var $::cfg_name wu {proc_break $$::cfg_name}
#       pack [checkbutton .f5.$::cfg_name -font efont -text $cfg_text -variable $::cfg_name -background grey85 ] -side top -anchor w
trace var tree_format wu ""
pack [checkbutton .f5.treeChk -font efont -text "List View" -variable tree_format -background grey85 ] -side top -anchor w
setToolTip .f5.treeChk "Filelist view (on list creation time): 0 - list, 1 - tree"

variable wish ""
pack [label .f6.labelTool -text "eshell>\n" -font efont -background grey85 ] -side left -anchor w
pack [entry .f6.entryCnsl -text $WorkSpace -font efont -textvariable wish -width 87] -side top -fill x
bind .f6.entryCnsl <Return> { eval $wish }

# Information about last command
pack [label .f6.label22 -font efontbold -textvariable last_command -foreground red -background grey85 ] -side left -fill y

# todo: create some implementation for it
# Note: top-level menu example
menu .mb
.mb add command -label "Feedback" -font efont -command {global email; global last_command; set last_command "Send your feedback to $email."} -background grey85

menu .mb.set
.mb add cascade -label "Settings" -font efont -menu .mb.set  -background grey85
.mb.set add command -label "hide" -font efont -command {global ExtendedSettings; set ExtendedSettings 1; ExtendSize} -background grey85
.mb.set add command -label "show" -font efont -command {global ExtendedSettings; set ExtendedSettings 0; ExtendSize} -background grey85
. configure -menu .mb
.mb.set configure -tearoff 0

# Note: small button to open/hide tool settings. todo: use !menu!
variable ExtendedSettings 0

# Note: this button duplicates top menu
proc ExtendSize {} {
   global ExtendedSettings;
   if $ExtendedSettings==1 {
      pack forget .f5
      set ExtendedSettings 0
      .f1.myButton<- configure -text "<-"
   } else {
      pack .f5 -side right -fill both -after .f1
      set ExtendedSettings 1
      .f1.myButton<- configure -text "->"
   }
}
