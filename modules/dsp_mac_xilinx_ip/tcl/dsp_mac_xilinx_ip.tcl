create_ip -name dsp_macro -vendor xilinx.com -library ip -version 1.0 -module_name dsp_mac_xilinx_ip
set_property -dict [list \
  CONFIG.a_binarywidth {0} \
  CONFIG.a_width {25} \
  CONFIG.c_binarywidth {0} \
  CONFIG.c_width {43} \
  CONFIG.p_binarywidth {0} \
  CONFIG.p_full_width {44} \
  CONFIG.p_width {44} \
] [get_ips dsp_mac_xilinx_ip]
generate_target all [get_files dsp_mac_xilinx_ip.xci]