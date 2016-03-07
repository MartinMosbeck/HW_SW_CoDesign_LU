onerror {resume}
add list /audiocore_simulation/dut/Iout
add list /audiocore_simulation/dut/Qout
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta none
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
