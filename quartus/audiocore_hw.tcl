# TCL File Generated by Component Editor 15.0
# Mon Jan 11 18:34:40 CET 2016
# DO NOT MODIFY


# 
# audiocore "audiocore" v1.0
#  2016.01.11.18:34:40
# 
# 

# 
# request TCL package from ACDS 15.0
# 
package require -exact qsys 15.0


# 
# module audiocore
# 
set_module_property DESCRIPTION ""
set_module_property NAME audiocore
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME audiocore
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL audiocore
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file audiocore.vhd VHDL PATH ../vhdl/audiocore/audiocore.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point asout
# 
add_interface asout avalon_streaming start
set_interface_property asout associatedClock clock
set_interface_property asout associatedReset reset
set_interface_property asout dataBitsPerSymbol 8
set_interface_property asout errorDescriptor ""
set_interface_property asout firstSymbolInHighOrderBits true
set_interface_property asout maxChannel 0
set_interface_property asout readyLatency 0
set_interface_property asout ENABLED true
set_interface_property asout EXPORT_OF ""
set_interface_property asout PORT_NAME_MAP ""
set_interface_property asout CMSIS_SVD_VARIABLES ""
set_interface_property asout SVD_ADDRESS_GROUP ""

add_interface_port asout asout_endofpacket endofpacket Output 1
add_interface_port asout asout_data data Output 32
add_interface_port asout asout_startofpacket startofpacket Output 1
add_interface_port asout asout_valid valid Output 1
add_interface_port asout asout_ready ready Input 1


# 
# connection point asin
# 
add_interface asin avalon_streaming end
set_interface_property asin associatedClock clock
set_interface_property asin associatedReset reset
set_interface_property asin dataBitsPerSymbol 8
set_interface_property asin errorDescriptor ""
set_interface_property asin firstSymbolInHighOrderBits true
set_interface_property asin maxChannel 0
set_interface_property asin readyLatency 2
set_interface_property asin ENABLED true
set_interface_property asin EXPORT_OF ""
set_interface_property asin PORT_NAME_MAP ""
set_interface_property asin CMSIS_SVD_VARIABLES ""
set_interface_property asin SVD_ADDRESS_GROUP ""

add_interface_port asin asin_data data Input 32
add_interface_port asin asin_startofpacket startofpacket Input 1
add_interface_port asin asin_endofpacket endofpacket Input 1
add_interface_port asin asin_valid valid Input 1
add_interface_port asin asin_ready ready Output 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset res_n reset_n Input 1

