`ifndef _cov_
`define _cov_

`include "ddr_base.sv"


class coverage;
  ddr_base base;
  covergroup cg;
  
  option.per_instance=1;
  
  Datain: coverpoint base.DATAIN {
                                  
                                  bins average ={[0:$]};
                                  }
  Addr: coverpoint base.ADDR {
                            
                                  bins average ={[0:$]};}
  //Cmd: coverpoint base.CMD;
  //CMDACK: coverpoint base.CMDACK;
  //DM: coverpoint base.DM;

endgroup


function new();
cg=new;

endfunction

task sample(ddr_base base);
  this.base=base;
  $display("entering into coverage");
cg.sample();
endtask

endclass

`endif
  





