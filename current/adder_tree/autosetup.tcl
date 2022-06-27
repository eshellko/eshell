read -DCASE1 ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

read -DCASE2 ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

read -DCASE3 ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

read -DCASE4 ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

read -DCASE5 ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

read -DCASE6 ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

read ../../etest/todo/adder_tree.v
build adder_tree
#synth
report_timing -summary
opt -recursive
opt -area
opt -time

exit
