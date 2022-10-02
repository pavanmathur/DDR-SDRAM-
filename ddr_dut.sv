`ifndef _dut_
`define _dut_

module dut(ddr_intf.dut inf);
  //wire [127:0] DOUT;
  
 // assign inf.DATAOUT = inf.DATAIN;

assign inf.DATAOUT = ((inf.CMD==3'b001)?inf.DATAIN : 128'b0); 
  //assign inf.DATAOUT=inf.DOUT;
  
  ddr_sdram dut_v(   
        .CLK(inf.CLK),
        .RESET_N(inf.RESET_N), 
        .ADDR(inf.ADDR), 
        .CMD(inf.CMD), 
        .CMDACK(inf.CMDACK), 
        .DATAIN(inf.DATAIN), 
        .DATAOUT(inf.DX), 
        .DM(inf.DM), 
        .SA(inf.SA), 
        .BA(inf.BA), 
        .CS_N(inf.CS_N), 
        .CKE(inf.CKE), 
        .RAS_N(inf.RAS_N), 
        .CAS_N(inf.CAS_N), 
        .WE_N(inf.WE_N), 
        .DQ(inf.DQ), 
        .DQM(inf.DQM), 
        .DQS(inf.DQS)    
        );
//ddr_sdram dut_v(inf);        
        
endmodule

`endif

