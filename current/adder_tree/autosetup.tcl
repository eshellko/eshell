read ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
#cpu 15
marker check ODC impact
opt -time
exit
