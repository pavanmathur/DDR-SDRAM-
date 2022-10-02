`ifndef _top_
`define _top_

`include "ddr_base.sv"
`include "configurations.sv"
`include "ddr_gen.sv"
`include "ddr_drv.sv"

`include "coverage_ddr.sv"
`include "ddr_monitor.sv"
`include "ddr_score.sv"
`include "ddr_env.sv"
`include "ddr_tb.sv"
module top();
  bit CLK;
  bit RESET_N;
  initial
  CLK = 1'b0;
  always #10 CLK = ~CLK;
  initial 
  RESET_N = 1'b0;
  always #10 RESET_N = 1'b1;
  
  ddr_intf inf(CLK,RESET_N);
  dut dut_inst(inf);
  tb  tb_inst(inf);
  ddr_sdram_tb tb_v(inf);
endmodule

`endif
