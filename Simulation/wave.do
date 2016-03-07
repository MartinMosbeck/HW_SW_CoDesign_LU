onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /audiocore_simulation/dut/Iin
add wave -noupdate -radix unsigned /audiocore_simulation/dut/Qin
add wave -noupdate -radix unsigned /audiocore_simulation/dut/Iout
add wave -noupdate -radix unsigned /audiocore_simulation/dut/Qout
add wave -noupdate /audiocore_simulation/dut/validout_cur
add wave -noupdate /audiocore_simulation/counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {543799 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 256
configure wave -valuecolwidth 244
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1029652 ps} {1103703 ps}
