# clean existing databases
clear_edb

# Lint mode
# message NOTE

# read HDL
read src/UART.v

# elaborate top module
build UART

# map

exit
