`ifndef _score_
`define _score_

`include "ddr_base.sv"
`include "coverage_ddr.sv"

class ddr_sb;
  mailbox gen2sb,mon2sb;
  bit [`DSIZE/2-1:0]DQ;
  bit cmp_en;
  coverage cov;
  
  function new(mailbox gen2sb,mon2sb);
    this.gen2sb = gen2sb;
    this.mon2sb = mon2sb;
    cov =new();
  endfunction
  
  extern task sb_run();
  extern task rcvd();
  extern task exptd();
endclass

task ddr_sb :: sb_run();
  $display($time,"SCOREBOARD :: Run Phase");
  fork
  rcvd();
  exptd();
  //cov.sample(base);
  join_none
endtask

task ddr_sb :: exptd();
  ddr_base base;
  while(1)begin
    gen2sb.get(base);
     cov.sample(base);
    if(base.CMD == 3'bxxx)begin
           base.ADDR = base.ADDR;
           base.CKE = base.CKE;
           base.CMDACK = base.CMDACK;
           base.SA = base.SA;
           base.BA = base.BA;
           base.WE_N = base.WE_N;
           base.CAS_N = base.CAS_N;
           base.RAS_N = base.RAS_N;
           base.DQM = base.DQM;
           base.DQ = base.DATAIN;
      //     cov.sample(base);
         
end
 end
endtask

task ddr_sb :: rcvd();
  ddr_base base;
  //cov.sample(base);
  while(1)begin
    mon2sb.get(base);
    
    
    if(base.DATAIN != base.DQ)
    begin
      $display($time,"SCOREBOARD --> MISMATCH :: Read data are not same\n");
    end
    else begin
    $display($time,"SCOREBOARD --> MATCHED :: Read data are same Addr =%d Actual Read Data=%d Exp.data=%d\n",base.ADDR,base.DATAOUT,base.DQ);
   end
   end
endtask

`endif

        
  
