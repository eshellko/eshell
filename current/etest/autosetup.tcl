"blackbox pins used in resource calculation" "\nunset break_vlog_on_systemverilog\nread rsrc.v\nbuild top\nopt" "SUCCEED" "3 (3) gates"
"unexpected end of file" "unexpected_eof.v" "FAILED" "unexpected end of file"
"generate instances array" "inst_loop.v\nbuild top\nopt -area" "SUCCEED" "ungroup module 'pass'" "ungroup module 'pass_1'"
"signed array index" "signed_index.v\nbuild signed_index\nopt" "SUCCEED" "32 (32) flops"

# xor_tree - do not do global xor decomposition...
# xor_cmp - create logic with less invertions where possible...
