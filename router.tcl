# Copyright (C) 1991-2010 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: router.tcl
# Generated on: Mon Sep 24 13:19:30 2012

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "router"]} {
		puts "Project router is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists router]} {
		project_open -revision router router
	} else {
		project_new -revision router router
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Stratix IV"
	set_global_assignment -name DEVICE EP4SGX230KF40C2
	set_global_assignment -name TOP_LEVEL_ENTITY NW_vc_router
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 9.1
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "16:40:26  FEBRUARY 26, 2011"
	set_global_assignment -name LAST_QUARTUS_VERSION "9.1 SP1"
	set_global_assignment -name EDA_DESIGN_ENTRY_SYNTHESIS_TOOL "<None>"
	set_global_assignment -name EDA_RUN_TOOL_AUTOMATICALLY OFF -section_id eda_design_synthesis
	set_global_assignment -name EDA_INPUT_DATA_FORMAT EDIF -section_id eda_design_synthesis
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/alpha_blending_mixer/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/asi/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/chroma_resampler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/cic/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/clipper/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/clocked_video_input/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/clocked_video_output/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/color_plane_sequencer/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/common/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/crc_compiler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/csc/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/ddr2_high_perf/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/ddr3_high_perf/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/ddr_ddr2_sdram/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/ddr_high_perf/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/deinterlacer/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/ed8b10b/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/fft/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/fir_compiler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/fir_filter_2d/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/frame_buffer/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/gamma_corrector/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/ht/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/line_buffer_compiler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/median_filter_2d/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/nco/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/nios2_ip/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/pci_compiler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/pci_express_compiler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/posphy_l2_l3/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/posphy_l4/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/qdrii_sram_controller/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/rapidio/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/reed_solomon/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/rldram_ii_controller/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/scaler/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/sdi/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/seriallite_ii/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/sopc_builder_ip/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/test_pattern_generator/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/triple_speed_ethernet/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/utopia2_master/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/utopia2_slave/lib/"
	set_global_assignment -name SEARCH_PATH "g:/altera/91/quartus/../ip/altera/viterbi/lib/"
	set_global_assignment -name VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
	set_global_assignment -name VERILOG_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 0.9V
	set_global_assignment -name VCCT_L_USER_VOLTAGE 1.1V
	set_global_assignment -name VCCT_R_USER_VOLTAGE 1.1V
	set_global_assignment -name VCCL_GXBL_USER_VOLTAGE 1.1V
	set_global_assignment -name VCCL_GXBR_USER_VOLTAGE 1.1V
	set_global_assignment -name VCCR_L_USER_VOLTAGE 1.1V
	set_global_assignment -name VCCR_R_USER_VOLTAGE 1.1V
	set_global_assignment -name VCCA_L_USER_VOLTAGE 2.5V
	set_global_assignment -name VCCA_R_USER_VOLTAGE 2.5V
	set_global_assignment -name VCCH_GXBL_USER_VOLTAGE 1.4V
	set_global_assignment -name VCCH_GXBR_USER_VOLTAGE 1.4V
	set_global_assignment -name POWER_HSSI_VCCHIP_LEFT "Opportunistically power off"
	set_global_assignment -name POWER_HSSI_VCCHIP_RIGHT "Opportunistically power off"
	set_global_assignment -name POWER_HSSI_LEFT "Opportunistically power off"
	set_global_assignment -name POWER_HSSI_RIGHT "Opportunistically power off"
	set_global_assignment -name VERILOG_FILE NW_pipereg.v
	set_global_assignment -name SDC_FILE timing_constrains_new.sdc
	set_global_assignment -name VERILOG_FILE NW_vc_router.v
	set_global_assignment -name VERILOG_FILE defines.v
	set_global_assignment -name VERILOG_FILE unary_to_bin_encoder.v
	set_global_assignment -name VERILOG_FILE NW_fifo.v
	set_global_assignment -name VERILOG_FILE NW_functions.v
	set_global_assignment -name VERILOG_FILE NW_matrix_arbiter.v
	set_global_assignment -name VERILOG_FILE NW_route.v
	set_global_assignment -name VERILOG_FILE NW_simple.v
	set_global_assignment -name VERILOG_FILE NW_tree_arbiter.v
	set_global_assignment -name VERILOG_FILE NW_vc_allocator.v
	set_global_assignment -name VERILOG_FILE NW_vc_arbiter.v
	set_global_assignment -name VERILOG_FILE NW_vc_buffers.v
	set_global_assignment -name VERILOG_FILE NW_vc_fc_out.v
	set_global_assignment -name VERILOG_FILE NW_vc_free_pool.v
	set_global_assignment -name VERILOG_FILE NW_vc_input_port.v
	set_global_assignment -name VERILOG_FILE NW_vc_status.v
	set_global_assignment -name VERILOG_FILE NW_vc_switch_allocator.v
	set_global_assignment -name VERILOG_FILE NW_vc_unrestricted_allocator.v
	set_global_assignment -name VERILOG_FILE parameters.v
	set_global_assignment -name VERILOG_FILE types.v
	set_global_assignment -name VERILOG_FILE unary_select_pair.v
	set_global_assignment -name TIMEQUEST_MULTICORNER_ANALYSIS ON
	set_global_assignment -name TIMEQUEST_DO_CCPP_REMOVAL ON
	set_global_assignment -name MISC_FILE "D:/#Ucheba/projects/netmaker_synthesis/router.dpf"
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[0].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[0].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[0].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[1].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[1].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[1].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[2].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[2].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[2].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[3].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[3].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[3].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[4].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[4].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_in[4].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[0].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[1].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[2].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[3].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_in[4].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to rst_n
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[0].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[0].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[0].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[1].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[1].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[1].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[2].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[2].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[2].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[3].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[3].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[3].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[4].credit[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[4].credit[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_cntrl_out[4].credit_valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[0].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[1].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[2].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[3].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.output_port[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.output_port[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.output_port[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.output_port[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.output_port[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.tail
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.valid
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.vc_id[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.vc_id[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.x_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.x_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.x_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.y_disp[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.y_disp[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].control.y_disp[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[0]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[1]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[2]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[3]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[4]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[5]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[6]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[7]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[8]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[9]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[10]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[11]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[12]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[13]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[14]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[15]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[16]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[17]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[18]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[19]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[20]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[21]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[22]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[23]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[24]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[25]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[26]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[27]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[28]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[29]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[30]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_flit_out[4].data[31]
	set_instance_assignment -name VIRTUAL_PIN ON -to i_input_full_flag
	set_instance_assignment -name VIRTUAL_PIN ON -to i_input_full_flag[0]
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
