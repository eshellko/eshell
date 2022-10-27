#!/usr/bin/wish
set eshell_gui 1
set eshell_tool 1 ; # Note: set if ESHELL launched at startup (in other case it will be cleared, and GUI can be used for any other tool)

# Feature Requests:
#
# TODO: add command-line argument (and parse it), that allows to not to run eshell on launch (for other tools usage; default: false)
#
# TODO: add "what is new" window with major news ... connect to web (if possible) site and receive news into this window ...
#       make small button for this (to show up) to not annoy user
#
# TODO: run 'sockets' between EGUI (tcl) and CORE (c++) to inform about completed command (and not tcl-done method)
#

if {![info exists ::env(ESHELL_HOME)]} {
   puts "   Error: ESHELL_HOME variable is not set."
   exit 1
}
set path $::env(ESHELL_HOME)
#
# Create fonts
#
#catch {font create efont -family Courier -size -12} ; # Note: -12 pixels, without '-' points !?
catch {font create efont -family Courier -size 12}
catch {font create efontbold -family Courier -size -14 -weight bold}
#catch {font create efont -family TimesNewRoman -size 13}
#catch {font create efontbold -family TimesNewRoman -size 13 -weight bold}
#
# Global variables
#
set sw_version "2016.04.30"
set ElaboratedDesign "" ; # Note: name of top-level from CSV, or set manually by user in combobox
variable WorkSpace "eshell"
set email kornukhin@mail.ru
set currentDir "."
set last_command "Initialize [pid]"
set testbench "" ; # Note: name of the testbench file (only one should be specified)
set constraints "\"\"" ; # Note: name of the SDC file (only one should be specified)
variable general_purpose_buffer ""
set ip_loaded 0 ; # Note: set when IP catalog loaded (only after IP tab selected to reduce boot time)
#
# Tool settings
#
wm title . "EHL Design Browser (workspace: $WorkSpace)"
#
# Note: placed at left upper position as specified by +0+0
#
wm geometry . 980x590+0+0
wm minsize . 487 590
#
# Note: ask confirmation and close tool
#
wm protocol . WM_DELETE_WINDOW {
    if {[tk_messageBox -message "Exit Design Browser?" -type yesno] eq "yes"} {
       EventOnBtnExit
    }
}
#
# Preload IP processor
#
source $path/tcl/egui_ip.tcl
#
# Utility
#
proc hex2dec {largeHex} {
   set res 0
   foreach hexDigit [split $largeHex {}] {
      set new 0x$hexDigit
      set res [expr {16*$res + $new}]
   }
   return $res
}

proc string2hex s {
   binary scan $s H* hex
   regsub -all (..) $hex {\1}
}

proc ReadEDB {filename} {
   set ex [ file exists $filename ]
   if { $ex == 1 } {
      set comboVal {}
      set fd [open $filename r]
         fconfigure $fd -translation binary
         while {![eof $fd]} {
            set desch [ read $fd 1 ]
            set descl [ read $fd 1 ]
            if {[eof $fd]} { break }
            set lineh [ string2hex $desch ]
            set linel [ string2hex $descl ]
            set vall [ hex2dec $linel ]
            set valh [ hex2dec $lineh ]
            set value [expr $valh * 256 + $vall  ]
            if {$value > 100} { break }
            set descr [ read $fd $value ]

            set desch [ read $fd 1 ]
            set descl [ read $fd 1 ]
            set lineh [ string2hex $desch ]
            set linel [ string2hex $descl ]
            set vall [ hex2dec $linel ]
            set valh [ hex2dec $lineh ]
            set value [expr $valh * 256 + $vall  ]
            if {$value > 100} { break }
            set descr [ read $fd $value ]

            lappend comboVal $descr
            set comboVal [ lsort -ascii -increasing $comboVal ]
            .f2.myComboBox configure -values $comboVal
         }
      close $fd
   }
}
#
# Note: redefines .log as stdout from commands
#
proc elog {message} {
   .log insert Infos end -text "$message" -tags "ttk simple"
   .log tag configure ttk -font efont
} 
###############################################
#
# Process CSV file's content
# TODO:
#      - provide another settings, sdc= to specify constraints
#      - provide another settings, lib= to specify liberty
#      - op_cond
#      - ... others...
#      keep liberty files in list, to allow reading of them... when synthesis run required...
#
###############################################
#
# Load custom flow processor
# TODO: add tag projdir= to allow prefix for all files into design... this will allow to run egui from some directory outside custom project
#
source $path/tcl/flow.tcl

proc read_csv fileName {
   EventOnBtnReloadEDB

   global ElaboratedDesign
   set ElaboratedDesign ""
   set filetop [.outer.f3.n.sources.tree children {}]
   .outer.f3.n.sources.tree delete $filetop
# TODO: check duplicate files... they will have duplicate IDs!!!
   set ex [ file exists $fileName ]
   if { $ex == 1 } {
      set fd [open $fileName r]
      while {![eof $fd]} {
         set fline [ read $fd ]
         foreach x [ split $fline ";\n"] {
            if [string length $x]>0 {
               if {[string range $x 0 3] eq "top="} {
                  set values [.f2.myComboBox cget -values]
                  set new_top [string range $x 4 end]
                  if {$new_top in $values} {
                     set ElaboratedDesign $new_top
                  }
#                   .outer.f3.n.project.tree insert top end -id top_level -text "Top-level module" -tags "ttk simple" -values [list [string range $x 4 end]]
               } elseif {[string range $x 0 3] eq "lib="} {
#                   .outer.f3.n.project.tree insert lib end -id [string range $x 4 end] -text "file:" -tags "ttk simple" -values [list [string range $x 4 end]]
               } elseif {[string range $x 0 4] eq "sgdc="} {
#                   .outer.f3.n.project.tree insert sgdc end -id [string range $x 5 end] -text "sgdc" -tags "ttk simple" -values [list [string range $x 5 end]]
               } elseif {[string range $x 0 2] eq "bb="} {
#                   .outer.f3.n.project.tree insert bb end -id [string range $x 3 end] -text "bb" -tags "ttk simple" -values [list [string range $x 3 end]]
               } elseif {[string range $x 0 5] eq "param="} {
#                   .outer.f3.n.project.tree insert param end -id [string range $x 6 end] -text "parameter" -tags "ttk simple" -values [list [string range $x 6 end]]
               } elseif {[string range $x 0 6] eq "define="} {
#                   .outer.f3.n.project.tree insert define end -id [string range $x 7 end] -text "define" -tags "ttk simple" -values [list [string range $x 7 end]]
               } elseif {[string range $x 0 6] eq "incdir="} {
#                   .outer.f3.n.project.tree insert incdir end -id [string range $x 7 end] -text "incdir" -tags "ttk simple" -values [list [string range $x 7 end]]
               } else {
# TODO: here file placed into list by 'checkFileHeader'; similar should be applied to SDC/VCD/LIB...
                  checkFileHeader $x 1
               }
            }
         }
      }
      close $fd
   }
   # Note: top_level filled during first run
# TODO: add Flow option to allow script generation for given CSV
#      gen_flow_eshell $ElaboratedDesign $fileName
}
###############################################
#
#
#
###############################################
# TODO: read prj.csv, load specified files into project; make incremental compilation on startup; add file on read; remove by rmb; save on change workspace or exit
#       modify check_header, to allow single file checking (separate procedure), for every file in project...
source $path/tcl/check_header.tcl
source $path/tcl/egui_btn.tcl
source $path/tcl/tclshrc.tcl
source $path/tcl/egui_layout.tcl
source $path/tcl/reference.tcl
#
# Note: disable buttons N/A for non-tool run
#
proc UpdateBtns {} {
   global eshell_tool anum button_cfg
   for {set i 0} {$i < $anum} {incr i} {
      set btn_name  [lindex $button_cfg($i) 1]
      if $eshell_tool==0 {
         set btn_state [lindex $button_cfg($i) 3]
         .f1.myButton$btn_name configure -state $btn_state
      } else {
         .f1.myButton$btn_name configure -state normal
      }
   }
}
proc DisableBtns {} {
   global anum button_cfg
   for {set i 0} {$i < $anum} {incr i} {
      set btn_name  [lindex $button_cfg($i) 1]
      .f1.myButton$btn_name configure -state disabled
   }
}

UpdateBtns
read_csv ${csv_search_path}/${WorkSpace}.csv
message $mesLev

# Note: to keep minsize as one created initially (automatically or using -geometry)
proc setDialogMinsize {window} {
   # this update will ensure that winfo will return the correct sizes
   update

   # get the current width and height
   set winWidth [winfo width $window]
   set winHeight [winfo height $window]

   # set it as the minimum size
   wm minsize $window $winWidth $winHeight
}

source $path/tcl/sdc_check.tcl
