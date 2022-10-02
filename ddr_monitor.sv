`ifndef _moni_
`define _moni_

`include "ddr_base.sv"
//`include "coverage_ddr.sv"
class ddr_moni;
  ddr_base base;
 // coverage cov;
  virtual ddr_intf inf;
  mailbox mon2sb;
  
  extern function new(virtual ddr_intf inf,mailbox mon2sb);
  extern task mon_run();
endclass

function ddr_moni :: new(virtual ddr_intf inf,mailbox mon2sb);
  this.inf = inf;
  this.mon2sb = mon2sb;
  //cov =new();
endfunction

task ddr_moni :: mon_run();
  begin
    ddr_base base;
    while(1)begin
      $display($time,"Data Matched :: Run Phase");
      
       @(posedge inf.cb or negedge inf.cb);
       if(inf.CMD == 3'bxxx) begin
         base = new();
         base.ADDR = inf.ADDR;
         base.CKE = inf.CKE;
         base.CMDACK = inf.CMDACK;
         base.SA = inf.SA;
         base.BA = inf.BA;
         base.WE_N = inf.WE_N;
         base.CAS_N = inf.CAS_N;
         base.RAS_N = inf.RAS_N;
         base.DQM = inf.DQM;
         base.DATAIN = inf.DATAIN;
         $display($time,"addr=%d,datain=%d",base.ADDR,base.DATAIN);
         //cov.sample(base);
         $display($time,"for coverage addr=%d,datain=%d",base.ADDR,base.DATAIN);
         mon2sb.put(base);
         
          
     end
     
   end
 end
 endtask
`endif
 
