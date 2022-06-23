marker CODE0
read 20211202.v
build top
opt
opt -area
report_timing
opt
opt -time
opt
report_timing -summary

marker CODE1 - BUG: not optimized well
marker   WHY we do not have 4-cut (from wider/deeper, but still) -- add level collector - with even search space
read -DIMPL1 20211202.v
build top
opt
opt -area
report_timing
opt
opt -time
opt
report_timing -summary
#write 1.v

marker CODE2
read -DIMPL2 20211202.v
build top
opt
opt -area
report_timing
opt
opt -time
opt
report_timing -summary

exit
