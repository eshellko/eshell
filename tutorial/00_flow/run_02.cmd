# clean existing databases
clear_db

# Lint mode
# message NOTE

# read HDL
read src/UART.v

# elaborate top module
build UART

# map

exit
