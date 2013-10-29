`ifndef PARAMETERS_V
`define PARAMETERS_V

`include "types.v"

/******* parameters.v **********/
parameter verbose=0;
parameter priority_switch_alloc_byflitid=0;
parameter router_num_vcs=2;
parameter sim_injection_rate=0.3;
parameter vcselect_usepacketmask=0;
parameter router_num_vcs_on_exit=2;
parameter router_num_vcs_on_entry=1;
parameter network_y=4;
parameter debug=0;
parameter priority_flit_bits=4;
parameter opt_specoutputportreq=0;
parameter vcselect_onlywhenempty=0;
parameter priority_flit_limit=4;
parameter uarch_explicit_pipeline_register=1;
parameter opt_meshxyturns=1;
parameter priority_singleflitpacketboost=0;
//parameter router_arch=VC;
parameter priority_flit_dynamic_switch_alloc=0;
parameter uarch_pipeline=1;
parameter network_x=4;
parameter priority_network_traffic=0;
parameter sim_packet_fixed_length=1;
parameter vcselect_leastfullbuffer=0;
parameter opt_noswitchreqifwasblocked=0;
parameter sim_packetb_length=5;
parameter vcselect_arbstateupdate=0;
parameter sim_packetab=0;
parameter vcselect_bydestinationnode=0;
parameter channel_latency=0;
parameter swalloc_speculative=0;
parameter sim_packet_length=4;
parameter priority_switch_alloc_byjourneylength=0;
parameter priority_flit_dynamic_vc_alloc=0;
parameter router_buf_len=4;
parameter sim_packeta_length=1;
parameter sim_measurement_packets=10;
parameter uarch_full_vc_check_before_switch_request=1;
parameter sim_packeta_prob=0.67;
parameter sim_warmup_packets=10;
parameter channel_data_width=16;
parameter router_radix=5;
parameter vcalloc_unrestricted=1;

`endif