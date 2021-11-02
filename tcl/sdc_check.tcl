proc read_sdc {filename} {
   global cnt_set_multicycle_path cnt_set_max_leakage_power cnt_set_operating_conditions cnt_set_disable_timing cnt_get_lib_cells cnt_get_pins cnt_get_cells cnt_get_clocks cnt_get_ports cnt_all_outputs cnt_all_inputs cnt_set_load cnt_create_clock cnt_set_clock_uncertainty cnt_set_clock_latency cnt_set_input_delay cnt_set_output_delay cnt_set_input_transition cnt_set_clock_transition cnt_set_false_path cnt_set_max_delay cnt_set_min_delay cnt_create_generated_clock cnt_set_ideal_net cnt_set_data_check cnt_set_case_analysis cnt_set_driving_cell cnt_set_clock_gating_check

   set cnt_set_multicycle_path 0
   set cnt_set_max_leakage_power 0
   set cnt_set_operating_conditions 0
   set cnt_set_disable_timing 0
   set cnt_get_lib_cells 0
   set cnt_get_pins 0
   set cnt_get_cells 0
   set cnt_get_clocks 0
   set cnt_get_ports 0
   set cnt_all_outputs 0
   set cnt_all_inputs 0
   set cnt_set_load 0
   set cnt_create_clock 0
   set cnt_set_clock_uncertainty 0
   set cnt_set_clock_latency 0
   set cnt_set_input_delay 0
   set cnt_set_output_delay 0
   set cnt_set_clock_transition 0
   set cnt_set_input_transition 0
   set cnt_set_false_path 0
   set cnt_set_max_delay 0
   set cnt_set_min_delay 0
   set cnt_create_generated_clock 0
   set cnt_set_ideal_net 0
   set cnt_set_data_check 0
   set cnt_set_case_analysis 0
   set cnt_set_driving_cell 0
   set cnt_set_clock_gating_check 0

   if { [ catch { source $filename } ] } {
	  global errorInfo
	  puts $errorInfo
   } else {
      elog "SDC commands call summary for file '$filename':"
      if {$cnt_set_multicycle_path > 0      } { elog "   cnt_set_multicycle_path  =  $cnt_set_multicycle_path" }
      if {$cnt_set_max_leakage_power > 0    } { elog "   set_max_leakage_power    =  $cnt_set_max_leakage_power" }
      if {$cnt_set_operating_conditions > 0 } { elog "   set_operating_conditions =  $cnt_set_operating_conditions" }
      if {$cnt_set_disable_timing > 0       } { elog "   set_disable_timing       =  $cnt_set_disable_timing" }
      if {$cnt_get_lib_cells > 0            } { elog "   get_lib_cells            =  $cnt_get_lib_cells" }
      if {$cnt_get_pins > 0                 } { elog "   get_pins                 =  $cnt_get_pins" }
      if {$cnt_get_cells > 0                } { elog "   get_cells                =  $cnt_get_cells" }
      if {$cnt_get_clocks > 0               } { elog "   get_clocks               =  $cnt_get_clocks" }
      if {$cnt_get_ports > 0                } { elog "   get_ports                =  $cnt_get_ports" }
      if {$cnt_all_outputs > 0              } { elog "   all_outputs              =  $cnt_all_outputs" }
      if {$cnt_all_inputs > 0               } { elog "   all_inputs               =  $cnt_all_inputs" }
      if {$cnt_set_load > 0                 } { elog "   set_load                 =  $cnt_set_load" }
      if {$cnt_create_clock > 0             } { elog "   create_clock             =  $cnt_create_clock" }
      if {$cnt_set_clock_uncertainty > 0    } { elog "   set_clock_uncertainty    =  $cnt_set_clock_uncertainty" }
      if {$cnt_set_clock_latency > 0        } { elog "   set_clock_latency        =  $cnt_set_clock_latency" }
      if {$cnt_set_input_delay > 0          } { elog "   set_input_delay          =  $cnt_set_input_delay" }
      if {$cnt_set_output_delay > 0         } { elog "   set_output_delay         =  $cnt_set_output_delay" }
      if {$cnt_set_clock_transition > 0     } { elog "   set_clock_transition     =  $cnt_set_clock_transition" }
      if {$cnt_set_input_transition > 0     } { elog "   set_input_transition     =  $cnt_set_input_transition" }
      if {$cnt_set_false_path > 0           } { elog "   set_false_path           =  $cnt_set_false_path" }
      if {$cnt_set_max_delay > 0            } { elog "   set_max_delay            =  $cnt_set_max_delay" }
      if {$cnt_set_min_delay > 0            } { elog "   set_min_delay            =  $cnt_set_min_delay" }
      if {$cnt_create_generated_clock > 0   } { elog "   create_generated_clock   =  $cnt_create_generated_clock" }
      if {$cnt_set_ideal_net > 0            } { elog "   set_ideal_net            =  $cnt_set_ideal_net" }
      if {$cnt_set_data_check > 0           } { elog "   set_data_check           =  $cnt_set_data_check" }
      if {$cnt_set_case_analysis > 0        } { elog "   set_case_analysis        =  $cnt_set_case_analysis" }
      if {$cnt_set_driving_cell  > 0        } { elog "   set_driving_cell         =  $cnt_set_driving_cell" }
      if {$cnt_set_clock_gating_check > 0   } { elog "   set_clock_gating_check   =  $cnt_set_clock_gating_check" }
   }
}

# todo: create list with all commands
set cnt_set_multicycle_path 0
set cnt_set_max_leakage_power 0
set cnt_set_operating_conditions 0
set cnt_set_disable_timing 0
set cnt_get_lib_cells 0
set cnt_get_pins 0
set cnt_get_cells 0
set cnt_get_clocks 0
set cnt_get_ports 0
set cnt_all_outputs 0
set cnt_all_inputs 0
set cnt_set_load 0
set cnt_create_clock 0
set cnt_set_clock_uncertainty 0
set cnt_set_clock_latency 0
set cnt_set_input_delay 0
set cnt_set_output_delay 0
set cnt_set_clock_transition 0
set cnt_set_input_transition 0
set cnt_set_false_path 0
set cnt_set_max_delay 0
set cnt_set_min_delay 0
set cnt_create_generated_clock 0
set cnt_set_ideal_net 0
set cnt_set_data_check 0
set cnt_set_case_analysis 0
set cnt_set_driving_cell 0
set cnt_set_clock_gating_check 0

# todo: run .exe client program with just parsed argument, which should call main server tool and get response (if data exist or not)
proc set_multicycle_path args { ; # { commentkey comment holdket hold fromkey from tokey to}
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_multicycle_path'"
}

proc set_max_leakage_power args { ; # {value}
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_max_leakage_power'"
}

proc set_operating_conditions args { ; # {value}
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_operating_conditions'"
}


proc set_disable_timing args { ; #{fromkey from tokey to objects}
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_disable_timing'"
}

proc get_lib_cells args { ; #{value} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'get_lib_cells'"
}

proc get_pins args { ; #{value} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'get_pins'"
}


proc get_clocks args { ; #{value} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'get_clocks'"
}

proc get_cells args { ; #{value} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'get_cells'"
}


proc get_ports args { ; #{value} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'get_ports'"
}


proc all_outputs args { ; #{} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'all_outputs'"
}


# todo: proceed every command like this
#proc set_multicycle_path args {
#    foreach arg $args {
#        puts "arg=$arg"
#    }
#}

proc all_inputs args {
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
   if {[llength $args]!=0} {
      puts "   Error: invalid number of parameters for '[lindex [info level 0] 0]'."
   }
# 1. launch sdc_all_inputs.exe
# 2.  connect to main server and get response with a text list of all inputs
# 3. return this list to caller function
# todo: for 'read_sdc' activated Tcl_Interp and run it with file... but still how to get connected to interpreted all_inputs?
#set AllInputs {"din" "clk"}
   # todo: return list of objects...
#return $AllInputs
}

#proc set_load { { key {} } value objects} { ; # Note: some of args could be optional
proc set_load args { ; #{ key value { objects {} } { pinloadkey {} } } ; # Note: some of args could be optional
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_load'"
}
###   #proc set_load { value objects args }
###   proc set_load { value objects args } { ; # key value objects
###      set args [dict merge { -max 1 -min 1 } $args ]
###      dict update args -max max -min min {}
###      #array set options { -min true -max true }  ; # default values
###   ##   array set options $args
###   ##   parray options
###   #   global cnt_set_load
###   #   set set_load [incr cnt_set_load]
###   puts "   Info: process 'set_load' $value $objects max:$max min:$min"
###   }

#proc create_clock {objects namekey name periodkey period} {
proc create_clock args { ; #{objects namekey name periodkey { period {} } { addkey {} } { waveformkey {} } { waveform {} } } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'create_clock' $period"
}
# declare create_clock {
#  {-period              Float      {$par>=0}	}
#  {-name                String     		}
#  {-waveform            List       {type_Float {length($length>=2 && ($length % 2)==0)} } }
#  {port_pin_list        List       		}
#  {-add                 Flag       		}
# } {param(-period) && (param(-name) || param(port_pin_list))}



proc set_clock_uncertainty args { ; #{value objects } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_clock_uncertainty' $value"
}

proc set_clock_latency args { ; #{value objects } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_clock_latency' $value"
}

#proc set_input_delay { { minkey {} } value clockkey clockname objects {addkey {}}} {
proc set_input_delay args { ; #{ minkey value clockkey { clockname {} } { objects {} } {addkey {}}} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_input_delay' $value"
}

#proc set_output_delay { {minkey {} } value clockkey clockname objects {addkey {}}} {
proc set_output_delay args { ; #{minkey value clockkey clockname { objects {} } {addkey {}}} 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_output_delay' $value"
}

proc set_clock_transition args { ; #{minkey value clocks } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_clock_transition' $value"
}

proc set_input_transition args { ; #{maxkey value objects } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_input_transition' $value"
}

proc set_false_path args { ; #{fromkey fromobj {tokey {}} {toobj {}} } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_false_path'"
}

#proc set_max_delay { fromkey fromobj {tokey {}} {toobj {}} value } {
proc set_max_delay args { ; #{ fromkey fromobj tokey {toobj {}} {value {}} } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_max_delay'"
}

#proc set_min_delay { fromkey fromobj {tokey {}} {toobj {}} value } {
proc set_min_delay args { ; #{ fromkey fromobj tokey {toobj {}} {value {}} } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_min_delay'"
}

#proc create_generated_clock { sourcekey source { dividebykey {} } { divider {} } namekey name object { combokey {} } } {
proc create_generated_clock args { ; #{ sourcekey source dividebykey divider namekey { name {} } { object {} } { combokey {} } } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'create_generated_clock'"
}

proc set_ideal_net args { ; #{ objects } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_ideal_net'"
}

proc set_data_check args { ; #{ tokey to fromkey from value { setupkey {} } } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_data_check'"
}

proc set_case_analysis args { ; #{ value object } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_case_analysis' $object = $value"
}

proc set_driving_cell args { ; #{ maxkey cellkey cellname ports { librarykey {}} { libraryname {} } { pinkey {} } { pinname {} } } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_driving_cell'"
}

proc set_clock_gating_check args { ; #{ setupkey value } 
   global cnt_[lindex [info level 0] 0]
   set [lindex [info level 0] 0] [incr cnt_[lindex [info level 0] 0]]
#   puts "   Info: process 'set_clock_gating_check'"
}

# Examples:
#read_sdc bsd.sdc
#read_sdc gpio.sdc
