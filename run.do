set UVM_VERBOSITY UVM_LOW
run 13235000ps
coverage save cov.ucdb
coverage report -detail -cvg
coverage report -summary
quit -f
