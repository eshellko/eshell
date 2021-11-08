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
#    #            f2            -    #
# f1 ###########################-    #
#    #                          -    #
#    #           f3             -    #
#    #                          -    #
#    ###########################- f5 #
#    #                          -    #
#    #          f4              -    #
#    #                          -    #
################################-    #
#               f6              -    #
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
#
# Buttons
#
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
   7  [ list 0 "IP"            EventOnBtnIP           normal ] \
   8  [ list 0 "Custom"        EventOnBtnCustom       normal ] \
   9  [ list 0 "Clear"         EventOnBtnClear        disabled ] \
   10 [ list 0 "Reload EDB"    EventOnBtnReloadEDB    disabled ] \
   11 [ list 0 "Bug Tracker"   EventOnBtnBugTracker   normal ] \
   12 [ list 0 "<-"            ExtendSize             normal ] \
   13 [ list 0 "Exit"          EventOnBtnExit         normal ] \
]

set anum [array size button_cfg]
for {set i 0} {$i < $anum} {incr i} {
   set btn_menu [lindex $button_cfg($i) 0]
   set btn_name [lindex $button_cfg($i) 1]
   set btn_hndl [lindex $button_cfg($i) 2]
# create button
   pack [button .f1.myButton$btn_name -relief groove -font efont -width 12 -text $btn_name -command $btn_hndl ] -side top -pady 1 -padx 2
   .f1.myButton$btn_name configure -background          [.f1 cget -background]
   .f1.myButton$btn_name configure -activebackground    [.f1 cget -background]
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

# Tree
set TreeRowsNum 8; #[expr 12-4]
pack [ ttk::treeview .outer.f3.tree -columns "Vendor Version Date Description" -displaycolumns "Description Date Version Vendor" -height $TreeRowsNum ] -side left -expand y -fill both
.outer.f3.tree heading Vendor      -text "Vendor"      -anchor w
.outer.f3.tree heading Version     -text "Version"     -anchor w
.outer.f3.tree heading Date        -text "Date"        -anchor w
.outer.f3.tree heading Description -text "Description" -anchor w
.outer.f3.tree heading #0          -text "Name"        -anchor w
.outer.f3.tree column #0          -width 160
.outer.f3.tree column Description -width 280
.outer.f3.tree column Date        -width 80
.outer.f3.tree column Version     -width 70
.outer.f3.tree column Vendor      -width 60
# scrollbar
pack [ scrollbar .outer.f3.sby -orient vert -width 12 ] -side right -fill y
.outer.f3.tree conf -yscrollcommand {.outer.f3.sby set}
.outer.f3.sby conf -command {.outer.f3.tree yview}
#
# Edit HDL
#
menu .popupMenu
.popupMenu configure -tearoff 0
.popupMenu add command -label "Edit HDL" -command "EventOnBtnEditHdl"
.popupMenu add command -label "View HDL" -command "EventOnBtnViewHdl"
.popupMenu add command -label "Compile" -command "EventOnBtnCompile"
proc EventOnBtnCompile {} {
   set filename [.outer.f3.tree focus]
   read_verilog $filename
   EventOnBtnReloadEDB
}
.popupMenu add command -label "Compile All" -command "EventOnBtnCompileAll" ; # -state disable ; # todo: add valid file name, not 'id'
 proc EventOnBtnCompileAll {} {
   set filetop [.outer.f3.tree children {}]
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
bind .outer.f3.tree <Button-3> {tk_popup .popupMenu %X %Y}
#
# Log
#
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
#
# ComboBox
#
pack [message .f2.myMessage -text "Current design" -width 100 -font efont -background grey85] -side left -padx 4
append EdbSpace $WorkSpace ".edb"
# Note: -height set in terms of text lines
pack [ttk::combobox .f2.myComboBox -textvariable ElaboratedDesign  -state readonly -font efont -height 20 ] -side left  -padx 4 ; # todo: place predefined packaged designs from sw_library in list
ReadEDB $EdbSpace
#
# Radiobutton
#
pack [label .f2.label1 -text "Message level" -font efont -background grey85] -side top -after .f2.myComboBox -anchor w -padx 30 -pady 4
pack [radiobutton .f2.errorBtn -text "Error"   -variable mesLev -command "message ERROR" -value "ERROR" -font efont -background grey85] -side left
pack [radiobutton .f2.warnBtn  -text "Warning" -variable mesLev -command "message WARN"  -value "WARN"  -font efont -background grey85] -side left
pack [radiobutton .f2.noteBtn  -text "Note"    -variable mesLev -command "message NOTE"  -value "NOTE"  -font efont -background grey85] -side left
.f2.errorBtn select
#
# Checkbutton
#
# Note: set default before trace, to avoid not necessary commands to eshell (on the other hand it will synchronize gui and console)
proc proc_break { var e op rr } {
   global eshell_tool
   if $eshell_tool==1 {
      start_cmd
      global io
      global $e
      if $$e==1 {
         puts $io "set $e"
      } else {
         puts $io "unset $e"
      }
   }
}   

set vlog_set { break_vlog_on_undirected_port break_vlog_on_tri01 break_vlog_on_verilog_xl_compiler_directive break_vlog_on_zero_width_constants break_vlog_on_systemverilog }
set vlog_text { "Break Vlog On Undirected Port" "Break Vlog On Tri Port" "Break Vlog On VerilogXL Compiler Directive" "Break Vlog On Zero Width Constants" "Break Vlog on SystemVerilog"}
set vlog_init {1 1 1 1 1}
set elab_set { break_elab_on_extra_parameter break_elab_on_extra_port break_elab_on_unreferenced_instance break_elab_on_missed_timescale}
set elab_text { "Break Elab On Extra Parameter" "Break Elab On Extra Port" "Break Elab On Unreferenced Instance" "Break Elab On Missed Timescale" }
set elab_init {1 1 1 1}
set tool_set {allow_incremental_compilation detect_xs_in_unary_plus append_parameters_to_build_module_name}
set tool_text {"Allow Incremental Compilation" "Detect Xs In Unary Plus" "Append Parameters To Build Module Name"}
set tool_init {0 1 0}

pack [label .f5.label4 -text "COMPILATION" -font efontbold -background grey85 ] -side top
foreach com $vlog_set text $vlog_text ini $vlog_init {
   variable $com $ini
   trace var $com wu {proc_break $$com}
   pack [checkbutton .f5.$com -font efont -text $text -variable $com -background grey85 ] -side top -anchor w
}
pack [label .f5.label5 -text "ELABORATION" -font efontbold -background grey85 ] -side top
foreach com $elab_set text $elab_text ini $elab_init {
   variable $com $ini
   trace var $com wu {proc_break $$com}
   pack [checkbutton .f5.$com -font efont -text $text -variable $com -background grey85 ] -side top -anchor w
}
pack [label .f5.label6 -text "SETTINGS" -font efontbold -background grey85 ] -side top
foreach com $tool_set text $tool_text ini $tool_init {
   variable $com $ini
   trace var $com wu {proc_break $$com}
   pack [checkbutton .f5.$com -font efont -text $text -variable $com -background grey85 ] -side top -anchor w
}
# Note: texts are same as  in help.cpp
setToolTip .f5.break_vlog_on_undirected_port "When set break the compilation if any port has no direction."
setToolTip .f5.break_vlog_on_tri01 "When set treat tri0/tri1 port types as wires; otherwise they are not supported. This nets should have pull-up/pull-down which is not supported by tool."
setToolTip .f5.break_vlog_on_verilog_xl_compiler_directive "When set break the compilation if Verilog-XL directive found. Otherwise directive (one of the suppress_faults, nosuppress_faults, enable_portfaults, disable_portfaults, delay_mode_path, delay_mode_unit, delay_mode_zero, delay_mode_distributed) ignored."
setToolTip .f5.break_vlog_on_zero_width_constants "When set break the compilation on constants with zero width. In other case treat them as 1'b0."
setToolTip .f5.break_elab_on_extra_parameter "When set break the elaboration if instance has connected parameters which are not present in instantiated module."
setToolTip .f5.break_elab_on_extra_port "When set break the elaboration if instance has connected ports which are not present in instantiated module."
setToolTip .f5.break_elab_on_unreferenced_instance "When set break elaboration if module referenced but not found in library."
setToolTip .f5.break_elab_on_missed_timescale "When set break the elaboration when some of the modules has timescale specified but other do not."
setToolTip .f5.allow_incremental_compilation ""
setToolTip .f5.detect_xs_in_unary_plus "Verilog standard doesn't clearly explain how to implement unary plus operator:\n(1) IEEE 1364-2005 5.1.5:\nFor the arithmetic operators, if any operand bit value is the unknown value x or the high-impedance value z, then the entire result should be x.\n(2) Table 5-7:\nUnary plus m (same as m).\nWhen detect_xs_in_unary_plus set - (1) implemented, otherwise (2).\nDefault is (1) should be treated as 'value if no Xs' as otherwise unary plus doesn't have any meaning."
setToolTip .f5.append_parameters_to_build_module_name "Append parameter name and value to elaborated module name. This allow find out what value were used to elaborate module. This option not affected top level module."

# Note: command line to customize GUI (ctrl-r executes specified command)
variable wish ""
pack [label .f6.labelCnsl -text "Tcl/Tk command line (Control-r to execute)" -font efont -background grey85 ] -side top -anchor w
pack [entry .f6.entryCnsl -text $WorkSpace -font efont -textvariable wish -width 87] -side top -fill x
bind . <Control-r> { eval $wish }

# Information about last command
pack [label .f6.label22 -font efontbold -textvariable last_command -foreground red -background grey85 ] -side left -fill y

# todo: create some implementation for it
# Note: top-level menu example
menu .mb
.mb add command -label "Feedback" -font efont -command {global email; global last_command; set last_command "Send your feedback to $email."}

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
