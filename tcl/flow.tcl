# TODO: check spaces in file names
###############################################
#
# Generate RTL filelist
#
###############################################
proc gen_flow_filelist {top_level fileName fileOut flow_lib flow_sgdc flow_sdc flow_bb flow_param flow_define flow_incdir flow_src flow_waive} {
   set ex [ file exists $fileName ]
   if { $ex == 1 } {
      set flow_fd [open $fileOut w]
      foreach it $flow_src {
         foreach x [ split $it " ;\n"] {
            if [string length $x]>0 {
               puts $flow_fd "[string range $x 0 end]"
            }
         }
      }
      close $flow_fd
   }
}
###############################################
#
# Generate reference flow for Eshell
#
###############################################
proc gen_flow_eshell {top_level fileName fileOut flow_lib flow_sgdc flow_sdc flow_bb flow_param flow_define flow_incdir flow_src flow_waive} {
   set ex [ file exists $fileName ] ; # Note: only if source file exist
   if { $ex == 1 } {
      set flow_fd [open $fileOut w]
      puts $flow_fd "# Info: this is automatically generated flow script for Eshell Signoff run"
      puts $flow_fd "clear_db"
      puts $flow_fd "unset ADV"
# TODO: set required (critical ADVs)
      puts $flow_fd "set ADV-1" ; #   "Note: 'ADV-1(%%d)' HDL contains identifier '%%s' with uppercase letters at line %%d",
      puts $flow_fd "set ADV-2" ; #   "Note: 'ADV-2(%%d)' module name '%%s' is not the same as file name '%%s'",
      puts $flow_fd "set ADV-22" ; #   "Warning: 'ADV_22(%%d)' using of %%s %%sWare component '%%s' at line %%d reduce portability",
      puts $flow_fd "set ADV-25" ; #   "Note: 'ADV-25(%%d)' Verilog-2005 doesn't require to use 'generate' keyword at line %%d",
      puts $flow_fd "set ADV-28" ; #   "Note: 'ADV-28(%%d)' workspace '%%s' contains modules unused for building current configuration of design '%%s': ...",
      puts $flow_fd "set ADV-30" ; #   "Note: 'ADV-30(%%d)' %%s keyword '%%s' used as identifier at line %%d",
      puts $flow_fd "set ADV-31" ; #"Note: 'ADV-31(%%d)' parameter '%%s' at line %%d will be treated as localparam (IEEE 1364-2001: 3.11.1)",
      puts $flow_fd "set ADV-34" ; #"Note: 'ADV-34(%%d)' IEEE 1364-2001 states that generate loop statement at line %%d must have generate_block_identifier, while IEEE 1364-2005 allows not to use it [Syntax 12-3 / Syntax 12-5]",
      puts $flow_fd "set ADV-56" ; #"Note: 'ADV-56(%%d)' '%%s' declared but not used inside module '%%s'", 
      puts $flow_fd "set ADV-64" ; #"Warning: 'ADV-64(%%d)' current release treats empty string (i.e. \"\") at line %%d as '1'h0' [IEEE 1364-2001. 4.2.3.3]",// todo:see readme and give link to sv -> 8'b0 should be
      puts $flow_fd "set ADV-65" ; #   "Note: 'ADV-65(%%d)' constant %%s at line %%d overflows specified limit and truncated to %%0d'b%%s [IEEE 1364-2005 3.5.1]",//   " Note: 'ADV-65' constant %%s at line %%d overflows limit specified by %%d bit%%s and truncated to 'b%%s [IEEE 1364-2005 3.5.1]",
      puts $flow_fd "set ADV-67" ; #   "Warning: 'ADV-67(%%d)' design '%%s' has partially redefined parameters: ..",
      puts $flow_fd "set ADV-70" ; #"Warning: 'ADV-70(%%d)' initial assignment to reg '%%s' at line %%d ignored",
      puts $flow_fd "set ADV-86" ; #"Warning: 'ADV-86(%%d)' implicit scalar net '%%s' of type %%s created for pin binding at line %%d", // todo: add setting to allow implicitly declared nets usage
      puts $flow_fd "set ADV-87" ; #   "Warning: 'ADV-87(%%d)' implicit scalar net '%%s' created for continuous assignment at line %%d",
      puts $flow_fd "set ADV-100" ; #   "Note: 'ADV-100(%%d)' %%s '%%s' never used nor assigned in %%s '%%s'",
      puts $flow_fd "set ADV-101" ; #   "Note: 'ADV-101(%%d)' %%s '%%s' never used in %%s '%%s'",
      puts $flow_fd "set ADV-102" ; #"Note: 'ADV-102(%%d)' %%s '%%s' never assigned in %%s '%%s'",
      puts $flow_fd "set ADV-115" ; #   "Note: 'ADV-115(%%d)' consider to use @* instead of @(...) at line %%d [IEEE 1364.1/IEC 62142]",
# Q:  "Warning: 'ADV-103(%%d)' '%%s' with zero width specification will be treated as 1'b0",
# Q: another same!?   "Note: 'ADV-118(%%d)' parameter '%%s' depends on other parameter '%%s', move it into module body and specify as localparam",
      puts $flow_fd "set ADV-120" ; #   "Note: 'ADV-120(%%d)' meaningless reduction unary operation '%%s' on scalar '%%s' at line %%d",
      puts $flow_fd "set ADV-131" ; #   "Warning: 'ADV-131(%%d)' variable '%%s' has no initial value associated with asynchronous control signal '%%s' although process '%%s' specifies it",
      puts $flow_fd "set ADV-135" ; #   "Warning: 'ADV-135(%%d)' width mismatch - port '%%s/%%s' is %%d %%s while port expression is %%d %%s",
      puts $flow_fd "set ADV-145" ; #   "Warning: 'ADV-145(%%d)' net '%%s/%%s' is multidriven", //  - wired AND assumed
      puts $flow_fd "set ADV-146" ; #   "Warning: 'ADV-146(%%d)' '%%s' referenced but not assigned in module '%%s'",
      puts $flow_fd "set ADV-160" ; #   "Warning: 'ADV-160(%%d)' timing loop found (node %%s/n_%%x) in module '%%s'",
      puts $flow_fd "set ADV-161" ; #   "Warning: 'ADV-161(%%d)' register '%%s' has asynchronous load control signal '%%s'",
      puts $flow_fd "set ADV-163" ; #"Warning: 'ADV-163(%%d)' out-of-bound (%%d, declared as [%%d:%%d]) read access to '%%s' returns %%d'bx",

      puts $flow_fd "message NOTE"
      puts $flow_fd "unset break_elab_on_missed_timescale"
      puts $flow_fd "unset break_vlog_on_systemverilog"

      foreach it $flow_lib {
         puts $flow_fd "read_lib -append $it"
      }

      foreach is $flow_src {
         puts -nonewline $flow_fd "read "
         if {$flow_define ne ""} {
            foreach it $flow_define {
               puts -nonewline $flow_fd "-D$it "
            }
         }
         if {$flow_incdir ne ""} {
             foreach it $flow_incdir {
                puts -nonewline $flow_fd "-I$it "
             }
         }
         puts $flow_fd " $is"
      }

      # Note: substitute = with space
      set flow_param [ regsub -all "=" $flow_param " " ]
      puts $flow_fd "build $top_level $flow_param"

      puts $flow_fd "opt"
      puts $flow_fd "report_design"
      puts $flow_fd "report_lint -clear"
      puts $flow_fd "report_hierarchy -resources -lib_cells"
      puts $flow_fd "report_timing -summary"
      puts $flow_fd "exit"
      close $flow_fd
   }
}
