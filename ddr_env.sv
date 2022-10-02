`ifndef _env_
`define _env_

`include "ddr_base.sv"
`include "configurations.sv"
`include "ddr_drv.sv"
`include "ddr_gen.sv"
`include "ddr_monitor.sv"
`include "ddr_score.sv"

class environment;
  ddr_base base;
  configurations cfg;
    ddr_drv drv;
    ddr_gen gen;
    ddr_moni moni;
    ddr_sb sb;
    virtual ddr_intf inf;
    mailbox gen2drv,gen2sb,mon2sb;
    function new(virtual ddr_intf inf,configurations cfg);
      gen2drv      = new();
      mon2sb       = new();
      gen2sb       = new(); 
      this.cfg     = cfg;
      this.inf     = inf; 
      gen          = new (cfg,gen2drv,gen2sb);
      drv          = new(base,inf,gen2drv);
      moni         = new (inf,mon2sb);
      sb           = new(gen2sb,mon2sb);
    endfunction
    
    task env_run();
        $display($time,"ENVIRONMENT :: Run Phase");
         fork
          gen.run();
          drv.drv_run();
          moni.mon_run();
          sb.sb_run();
        join
    endtask 

endclass
`endif

      
