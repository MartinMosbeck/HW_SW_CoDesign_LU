onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /audiocore_simulation/dut/Iin
add wave -noupdate /audiocore_simulation/dut/Qin
add wave -noupdate /audiocore_simulation/dut/validin
add wave -noupdate -radix hexadecimal /audiocore_simulation/dut/Iout
add wave -noupdate -radix hexadecimal /audiocore_simulation/dut/Qout
add wave -noupdate /audiocore_simulation/dut/validout
add wave -noupdate /audiocore_simulation/dut/clk
add wave -noupdate -label res_n /audiocore_simulation/dut/res_n
add wave -noupdate -radix decimal /audiocore_simulation/dut/Iout_cur
add wave -noupdate -radix decimal /audiocore_simulation/dut/Qout_cur
add wave -noupdate /audiocore_simulation/dut/validintern_cur
add wave -noupdate -radix decimal /audiocore_simulation/dut/Itemp1_cur
add wave -noupdate -radix decimal /audiocore_simulation/dut/Itemp2_cur
add wave -noupdate -radix decimal /audiocore_simulation/dut/Qtemp1_cur
add wave -noupdate -radix decimal /audiocore_simulation/dut/Qtemp2_cur
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {187458 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 195
configure wave -valuecolwidth 93
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {171639 ps}
