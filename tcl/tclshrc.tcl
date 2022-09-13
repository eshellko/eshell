if { ! [info exist eshell_gui] } {
   set eshell_gui 0
}

# Note: eshell.exe should be in your $PATH or %path% variable (or into env(ESHELL_HOME))

set tcl_prompt1 {puts -nonewline "eshell-tcl> "}

#######################################################
source $path/tcl/parse_options.tcl
set tool_arguments [list ] ; # todo: do not clear after convertion will be made
#######################################################
set io 0
if { [catch { global io ; set io [ open "|eshell.exe $tool_arguments -noinit -tcl" r+ ] } ] } {
   if {[info exists ::env(ESHELL_HOME)]} {
      set path $env(ESHELL_HOME)
      if { [catch { global io ; set io [ open "|$path/eshell.exe $tool_arguments -noinit -tcl" r+ ] } ] } {
         global last_command
         set last_command "Error: can't find eshell.exe file. Make sure it's in your PATH variable, or ESHELL_HOME points to valid location."
         global eshell_tool
         set eshell_tool 0
      }
   }
}

if $eshell_tool==1 {
   fconfigure $io -buffering line -blocking 0 -translation crlf
   fconfigure $io -buffering line -blocking 1 -translation crlf
}
# Note: Linux requires 'lf'
set os $tcl_platform(os)
set os1 [string range $os 0 2]
if {$os1 ne "Win"} {
   if $eshell_tool==1 {
      fconfigure $io -buffering line -blocking 1 -translation lf
   }
}
if $eshell_tool==1 {
   fconfigure $io -buffering none -blocking 0
   ################################
   # set handler for IO channel
   ################################
# A channel is considered to be readable if there is unread data available on the underlying device.
# A channel is also considered to be readable if there is unread data in an input buffer, except in
#   the special case where the most recent attempt to read from the channel was a gets call that           -- GETS call could not find EOL
#   could not find a complete line in the input buffer. This feature allows a file to be read a line
#   at a time in nonblocking mode using events. A channel is also considered to be readable if an
#   end of file or error condition is present on the underlying file or device. It is important
#   for script to check for these conditions and handle them appropriately; for example, if there          -- check EOF
#   is no special check for end of file, an infinite loop may occur where script reads no data,            -- channel $io closed
#   returns, and is immediately invoked again. 
   fileevent $io readable "ToolLogHndlr $io"
}
set mutex 0

# TODO: get data interactively - ASAP it is provided... and not to HALT when point something during workmode!?
proc ToolLogHndlr {chan} {
   global eshell_tool
   if $eshell_tool==1 {
      if {![eof $chan]} {
         set line [gets $chan]
         if { $line eq "tcl-done" } {
            stop_cmd
         } else {
            .outer.f4.text configure -state normal
            set pos [ .outer.f4.text index end ]
# BUG: +0.3 -1.0 gives rounding problem inside TCL core (todo: research in more details)
#      as workaround order of operations changed (but feels that it just masks problem but not solves it...)
            .outer.f4.text insert end "$line\n"

            set type_of_textR [string range $line 3 8]
            if [string match "Error:" $type_of_textR] {
               .outer.f4.text tag configure highlightR -foreground red
               set pos1 [expr $pos - 1.0 + 0.3]
               set pos2 [expr $pos - 1.0 + 0.9]
               .outer.f4.text tag add highlightR $pos1 $pos2
            }

            set type_of_textR [string range $line 3 17]
            if [string match "Internal error:" $type_of_textR] {
               .outer.f4.text tag configure highlightR -foreground red
               set pos1 [expr $pos - 1.0 + 0.3]
               set pos2 [expr $pos - 1.0 + 0.18]
               .outer.f4.text tag add highlightR $pos1 $pos2
            }

            set type_of_textB [string range $line 3 10]
            if [string match "Warning:" $type_of_textB] {
               .outer.f4.text tag configure highlightB -foreground blue
               set pos1 [expr $pos - 1.0 + 0.3]
               set pos2 [expr $pos - 1.0 + 0.11]
               .outer.f4.text tag add highlightB $pos1 $pos2
            }

            set type_of_textG [string range $line 3 7]
            if [string match "Note:" $type_of_textG] {
               .outer.f4.text tag configure highlightG -foreground green
               set pos1 [expr $pos - 1.0 + 0.3]
               set pos2 [expr $pos - 1.0 + 0.8]
               .outer.f4.text tag add highlightG $pos1 $pos2
            }

            .outer.f4.text see end
            .outer.f4.text configure -state disabled
         }
        # Note: closed on EOF from tool
      } else { close $chan; }
   }
}
# Note: start command execution:
#       - activate progress bar
# TODO: disable buttons as well
proc start_cmd {} {
   global mutex
   if $mutex==1 {
      set mutex 0
      .f1.progress start
      DisableBtns
   }
# TODO: disable settings and combo as well
}
proc stop_cmd {} {
   global mutex
   UpdateBtns
   .f1.progress stop ; # Note: stop progress bar here in a single place, while it can be started on any command invocation
   set mutex 1
}

# sdc commands should be native tool commands... and every SDC command, like get_* should ask tool to provide such an info...
#                    set sdc_set { all_clocks all_inputs all_instances all_outputs all_registers create_clock create_generated_clock current_design current_instance filter_collection get_cell get_clock get_design get_generated_clocks get_lib get_lib_cell get_lib_pin get_lib_timing_arcs get_net get_object_name get_path_groups get_pin get_port getenv group_path remove_clock_gating_check remove_clock_latency remove_disable_clock_gating_check remove_generated_clock remove_ideal_net remove_ideal_network remove_input_delay remove_output_delay set_case_analysis set_clock_gating_check set_clock_groups set_clock_latency set_clock_sense set_clock_skew set_clock_transition set_clock_uncertainty set_data_check set_disable_clock_gating_check set_dont_touch set_dont_touch_network set_dont_use set_drive set_driving_cell set_equal set_false_path set_fanout_load set_hierarchy_separator set_ideal_net set_ideal_network set_input_delay set_input_transition set_lib_pin set_load set_load_unit set_logic_dc set_logic_one set_logic_zero set_max_capacitance set_max_delay set_max_dynamic_power set_max_fanout set_max_leakage_power set_max_time_borrow set_max_transition set_min_delay set_mode set_multicycle_path set_operating_conditions set_opposite set_output_delay set_path_adjust set_port_fanout_number set_timing_derate set_time_unit set_unconnected set_units set_wire_load_mode set_wire_load_model set_wire_load_selection_group sizeof_collection \
#                    get_pins }

set command_set { build \
                  clear_db cpu \
				  _exit \
				  get_customer_info get_designs get_instances get_ports \
				  _help _history lec man message mif2rom \
				  opt techmap \
				  _read read_lib _read_sdc read_vcd \
				  report_hierarchy report_blackbox report_design report_libs report_lint report_resources report_settings report_timing report_uninitialized report_vcd report_workspace   report_d_flops \
				  set_workspace _source system \
				  write \
				  skip endskip \
				  }
#                    append command_set $sdc_set
foreach cs $command_set {
   proc $cs args {
      global eshell_tool io
      if $eshell_tool==1 {
         start_cmd
         # Note: provide arguments as text string and not as tcl list with '{}'
         set CMD "[lindex [info level 0] 0] "
         foreach arg $args {
            set CMD "$CMD $arg"
         }
         TOOL_CMD "$CMD"
      }
   }
}

# Note: wrappers for eshell commands that has same names as tcl
#       in tcl mode they have different names.
#       ESHELL     TCL
#      ================================
#       exit       quit
#       read       read_verilog
####################       set        sete
####################       unset      unsete
proc quit {} {
   global eshell_tool io
   if $eshell_tool==1 {
      start_cmd
      TOOL_CMD "exit"
      close $io
   }
   exit
}
proc read_verilog args {
   global eshell_tool
   if $eshell_tool==1 {
      start_cmd
      TOOL_CMD "read $args"
   }
}
#
# Wrapper above command, sent to tool
# TODO: implement funcitonality
# It checks for channel status before send command
# If channel is closed - error written into console
#
proc TOOL_CMD arg {
   global io
   if {![eof $io]} {
      puts $io "$arg"
   } else {
#   puts "can't do it!!!"
   }
}

# Note: autosetup.tcl is eshell file, not eshell-tcl, using different name (tclsetup.tcl) here
set AUTOSETUP_FILENAME tclsetup.tcl
if $eshell_gui==0 {
   if [file exist $AUTOSETUP_FILENAME] {
      if { [ catch { source $AUTOSETUP_FILENAME } ] } {
         puts $errorInfo
      }
   } else {
      puts "   Info: no default '$AUTOSETUP_FILENAME' file present."
   }
} 
