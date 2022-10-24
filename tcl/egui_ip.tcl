# Feature Requests:
# TODO: write additional checks for IPs, when parameters depend on each other
# TODO: also generate SDC files
# TODO: parse headers of IP files and get versions from there... file paths should be specified...
# TODO: add IP description text
#          example for ecc: decoder/encoder core for data protecting with Hamming code. Allows to detect double errors, and correct single error. Additional bits required for data width is as follows 8 for 64 bit data, 7 for 32, 6 for 16 and 5 for 8.
# TODO: based on IP Name write top-level wrapper with user defined parameters and run 'make export ip=...' to get IP with specified (allowed) encryption level
#          not wrapper but instantiation example in a pretty format

proc configureIP {} {
   global last_command
   global ip_parameters ip_ptypes ip_init_values ip_allowed_values ip_descriptions ip_names ip_vendor ip_version ip_doc
   set ip_name [.outer.f3.n.ip.tree focus]
   # Note: check there is selection; otherwise access to '$ip_names($ip_name)' cause segmentation fault
   if {[string length $ip_name] == 0} {
      tk_messageBox -message "no IP selected"
      return 0
   }
   catch [ destroy .${ip_name} ]
   set last_command "Configure EHL $ip_names($ip_name)."

   proc GENERATE_CMD ip_name {
      global ip_parameters ip_ptypes ip_init_values ip_names
      # Note: looking for design into current compiled library
      set values [.f2.myComboBox cget -values]
      if {$ip_names($ip_name) in $values} {
         set build_arg "$ip_names($ip_name)"
         set cnt [llength $ip_parameters(${ip_name})]
# TODO: define MAX width of parameter name to write offsets ... so far 'format' used
         foreach y $ip_parameters(${ip_name}) q $ip_init_values(${ip_name}) {
            set rrr ${ip_name}_combo_$y
            global $rrr
            set build_arg "$build_arg $y "
            set build_arg "$build_arg [set $rrr] "
            set cnt [expr $cnt - 1]
         }
# eval make export-ip ip=ddr
         build $build_arg
# TODO: 2nd waiter mutex required here, as GUI already completed while toll still dumps netlist as a second command...
         write "$ip_names($ip_name)_egui_netlist.v"
         # Note: VAR updated and GUI that sets this variable...
         global ElaboratedDesign
         set ElaboratedDesign $ip_names($ip_name)
# TODO: this design is active right now - probably close it?
      } else {
         global last_command
         set last_command "   Error: design $ip_names($ip_name) is not compiled."
      }
   }

   toplevel .${ip_name}
   wm title .${ip_name} "Configure EHL ($ip_vendor($ip_name)) '$ip_names($ip_name)' (ver. $ip_version($ip_name)) IP Core."
   # Note: window made little transparent
   wm attributes .${ip_name} -alpha 0.8

   set xpos 20
   set ypos 20

   set descr ip_descriptions($ip_name)
   set param ip_parameters($ip_name)
   set ptype ip_ptypes($ip_name)
   set allow ip_allowed_values($ip_name)
   set init  ip_init_values($ip_name)

   foreach x [set $descr] y [set $param] z [set $allow] q [set $init] t [set $ptype] {
      global ${ip_name}_combo_$y
      set ${ip_name}_combo_$y $q
      catch [ destroy .${ip_name}.label$y ]
      catch [ destroy .${ip_name}.${ip_name}_combo$y ]
      place [label .${ip_name}.label$y -text $x -font efont ] -x $xpos -y $ypos
      # Note: combobox with values for type A, text box with initial value for type B
      if [string equal $t "A"] {
         place [ttk::combobox .${ip_name}.${ip_name}_combo$y -textvariable ${ip_name}_combo_$y -state readonly -values $z -font efont -width 15 ] -x 440 -y $ypos
      } elseif [string equal $t "B"] {
         place [entry .${ip_name}.${ip_name}_entry$y -text $z -font efont -textvariable ${ip_name}_combo_$y -width 15 ] -x 440 -y $ypos
      }
      set ypos [expr $ypos + 30 - 10]
      # tooltip text - TODO: write description into separate field, and brief one for text -- check long description in highlight will be moved into next line
#      set listab $x
      setToolTip .${ip_name}.label$y $x
   }

   place [button .${ip_name}.button0 -text "Doc"      -font efont -width 10 -command "catch { exec firefox $::env(ESHELL_HOME)/ehl/$ip_doc(${ip_name}) }" ] -x 615 -y 20
   place [button .${ip_name}.button1 -text "Generate" -font efont -width 10 -command "GENERATE_CMD $ip_name"] -x 615 -y 60
   place [button .${ip_name}.button2 -text "Done"     -font efont -width 10 -command "destroy .${ip_name}" ] -x 615 -y 100

   set ypos [expr $ypos + 20]
   if $ypos<190 {set ypos 190}
   wm geometry .${ip_name} 760x$ypos+100+100
}
