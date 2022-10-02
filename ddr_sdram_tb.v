//`timescale 1ns / 100ps 
 
module ddr_sdram_tb(); 
 `include "mt46v4m16.v"
 `include "ddr_sdram.v"
 
// defines for the testbench 
`define         BL              8               // burst length 
`define         CL              3               // cas latency 
`define         RCD             2               // RCD 
`define         LOOP_LENGTH     1024            // memory test loop length 
 
 
`include        "params.v" 
 
 
reg                             clk;                    // Generated System Clock 
reg                             clk2;                   // staggered system clock for sdram models 
 
reg                             reset_n;                // Reset 
 
reg     [2:0]                   cmd;                    // Command bus 
reg     [`ASIZE-1:0]            addr;                   // Address 
reg                             ref_ack;                
reg     [`DSIZE-1:0]            datain; 
reg     [`DSIZE/8-1:0]          dm; 
 
//reg                            CLK100;
//reg                            CLK200; 
wire                            cmdack; 
wire    [`DSIZE-1:0]            dataout; 
wire    [11:0]                  sa; 
wire    [1:0]                   ba; 
wire    [1:0]                   cs_n; 
wire                            cke; 
wire                            ras_n; 
wire                            cas_n; 
wire                            we_n; 
wire    [`DSIZE/2-1:0]          dq; 
wire    [`DSIZE/16-1:0]         dqm; 
wire    [`DSIZE/16-1:0]         dqs; 
 
reg     [`DSIZE-1:0]            test_data; 
reg     [`ASIZE-1:0]            test_addr; 
reg     [11:0]                  mode_reg; 
 
 
integer                         j; 
integer                         x,y,z; 
integer                         bl; 
 
 
//instantiate the controller 
ddr_sdram ddr_sdram1 ( 
                .CLK(clk), 
                .RESET_N(reset_n), 
                .ADDR(addr), 
                .CMD(cmd), 
                .CMDACK(cmdack), 
                .DATAIN(datain), 
                .DATAOUT(dataout), 
                .DM(dm), 
                .SA(sa), 
                .BA(ba), 
                .CS_N(cs_n), 
                .CKE(cke), 
                .RAS_N(ras_n), 
                .CAS_N(cas_n), 
                .WE_N(we_n), 
                .DQ(dq), 
                .DQM(dqm), 
                .DQS(dqs) 
                ); 
 
// instantiate the memory models 
mt46v4m16 mem000      (.Dq(dq[15:0]), 
                        .Dqs(dqs[0]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[0]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[1:0])); 
 
mt46v4m16 mem001      (.Dq(dq[31:16]), 
                        .Dqs(dqs[1]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[0]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[3:2])); 
 
mt46v4m16 mem010      (.Dq(dq[47:32]), 
                        .Dqs(dqs[2]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[0]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[5:4])); 
 
mt46v4m16 mem011      (.Dq(dq[63:48]), 
                        .Dqs(dqs[3]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[0]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[7:6])); 
 
mt46v4m16 mem100      (.Dq(dq[15:0]), 
                        .Dqs(dqs[0]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[1]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[1:0])); 
 
mt46v4m16 mem101      (.Dq(dq[31:16]), 
                        .Dqs(dqs[1]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[1]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[3:2])); 
mt46v4m16 mem110      (.Dq(dq[47:32]), 
                        .Dqs(dqs[2]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[1]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[5:4])); 
mt46v4m16 mem111      (.Dq(dq[63:48]), 
                        .Dqs(dqs[3]), 
                        .Addr(sa[11:0]), 
                        .Ba(ba), 
                        .Clk(clk2), 
                        .Clk_n(!clk2), 
                        .Cke(cke), 
                        .Cs_n(cs_n[1]), 
                        .Cas_n(cas_n), 
                        .Ras_n(ras_n), 
                        .We_n(we_n), 
                        .Dm(dqm[7:6])); 
 
initial begin 
        clk = 1;                        // initialize clocks 
        clk2 = 1; 
        reset_n = 0;                    // do a reset 
        #100 reset_n = 1; 
end 
 
always begin 
        #3 clk2 = ~clk2; 
        #2 clk = ~clk; 
end 

/*initial begin
CLK100 = clk;
CLK200 = clk2;
end
always begin
CLK100 = ~CLK100;
CLK200 = ~CLK200;
end*/ 
 
//      write_burst(address, start_value, data_mask, RCD, BL) 
// 
//      This task performs a write access of size burst_length  
//      at SDRAM address to the SDRAM controller 
// 
//      address         : 	Address in SDRAM to start the burst access 
//      start_value     :     Starting value for the burst write sequence.  The write burst task 
//                              simply increments the data values from the start_value. 
//      data_mask       :     Byte data mask for all cycles in the burst 
//      RCD             :     RAS to CAS delay as programmed into the controller. 
//      BL              :     Burst length 
 
task    burst_write; 
	 
        input [`ASIZE-1   : 0]    address; 
        input [`DSIZE-1   : 0]    start_value; 
        input [`DSIZE/8-1 : 0]    data_mask; 
        input [1 : 0]             RCD; 
        input [3 : 0]             BL; 
 
        integer                 i; 
 
        begin 
                addr <= address;                  // Assert the address 
                cmd  <= 3'b010;                   // Assert the WRITEA command 
                datain <= start_value;            // Setup the first data and  
                dm     <= data_mask;              //   data mask value 
                @(cmdack==1);                     // Wait for ACK from controller 
                cmd  <= 3'b000;                   // issue a NOP after the ack 
                for (i=1 ; i<=(RCD-1); i=i+1)     // Wait until RCD has expired before clocking 
                @(posedge clk or negedge clk);                   // data into the controller 
                for(i = 1; i <= BL; i = i + 1)     
                begin 
                        #2; 
                        datain <= start_value + i;     // clock the data in 
                        #2; 
                        @(posedge clk or negedge clk); 
                        
                end 
                dm <= 0;	 
        end 
endtask 
 
 
 
//      burst_read(address, start_value, CL, RCD, BL) 
// 
//      This task performs a read access of size burst_length  
//      at SDRAM address to the SDRAM controller 
// 
//      address         :       Address in SDRAM to start the burst access 
//      start_value     :       Starting value for the burst write sequence.  The write burst task 
//                              simply increments the data values from the start_value. 
//      CL              :       CAS latency 
//      RCD             :       RAS to CAS delay as programmed into the controller 
//      BL              :       Burst Length 
 
task    burst_read; 
	 
        input   [`ASIZE-1 : 0]	     address; 
        input   [`DSIZE-1 : 0]          start_value; 
        input   [2 : 0]                 CL; 
        input   [1 : 0]                 RCD; 
        input   [3 : 0]                 BL; 
        integer                         i; 
        integer                         ddr_cl; 
        reg     [`DSIZE-1 : 0]          read_data; 
         
        begin 
                if (CL == 2) 
                        ddr_cl <= 2;                   //cas latency = 2.0 
                if (CL == 3) 
                        ddr_cl <= 2;                   //cas latency = 2.5 
                if (CL == 4) 
                        ddr_cl <= 3;                   //cas latency = 3.0; 
                         
                addr  <= address;                      // Setup the requested address 
                cmd   <= 3'b001;                       // Issue a burst read command 
                @(cmdack == 1);                        // wait for the ack from the controller 
                @(posedge clk or negedge clk);     
                cmd <= 3'b000;                         // Issue a NOP 
                for (i=1 ; i<=(ddr_cl+RCD+4); i=i+1)   // wait for RCD to pass 
                @(posedge clk or negedge clk); 
                for(i = 1; i <= BL; i = i + 1) 
                begin 
                        @(posedge clk or negedge clk); 
                        read_data <= dataout;          // capture the read data 
                        #2; 
                        if (read_data !== start_value + i - 1) 
                        begin 
                                $display("Read error at %h read %h expected %h", (addr+i-1), read_data, (start_value + i -1)); 
                                $stop; 
                        end 
                end	 
        end 
endtask 
 
//      config(bl, cl, rc, pm, ref) 
// 
//      This task cofigures the SDRAM devices and the controller  
// 
//      bl         :       Burst length 2,4, or 8 
//      cl         :       Cas latency, 2 or 3 
//      rc         :       Ras to Cas delay. 
//      pm         :       page mode setting 
//      ref        :       refresh period setting 
 
 
task config1; 
	 
        input   [3 : 0]	       bl; 
        input   [2 : 0]         cl; 
        input   [1 : 0]         rc; 
        input                   pm; 
        input   [15: 0]         ref; 
         
        reg     [`ASIZE-1 : 0]  config_data; 
         
        begin 
   
                config_data <= 0; 
                @(posedge clk or negedge clk); 
                                                           
                @(posedge clk or negedge clk); 
                if (bl == 2) 
                        config_data[2:0] <= 3'b001;         // set the burst length bits 
                else if (bl == 4) 
                        config_data[2:0] <= 3'b010; 
                else if (bl == 8) 
                        config_data[2:0] <= 3'b011; 
                         
                if (cl == 2) 
                        config_data[6:4] <= 3'b010;         // set the cas latency bits 
                else if (cl == 3) 
                        config_data[6:4] <= 3'b110; 
                else if (cl == 4) 
                        config_data[6:4] <= 3'b011; 
                 
                         
         
                                                         // issue precharge before issuing load_mode 
                @(posedge clk or negedge clk); 
                cmd <= 3'b100;                           // Issupe precharge command 
                @(cmdack == 1)                           // wait for acknowledge from controller 
                #2; 
                cmd <= 3'b000;                           // NOP 
 
                @(posedge clk or negedge clk); 
                #2; 
         
                                                        // load mode register 
                cmd <= 3'b101;                          // issued the load mode command 
                addr[15:0] <= config_data;              // put the config data onto the address bus 
                @(cmdack == 1)                          // wait for an ack from the controller 
                cmd <= 3'b000;                          // NOP 
 
                @(posedge clk or negedge clk); 
                @(posedge clk or negedge clk); 
   
   
                config_data <= 0; 
                config_data[15:0] <= ref;                // set the refresh value 
                @(posedge clk or negedge clk); 
                                                         // load refresh counter 
                @(posedge clk or negedge clk); 
                addr[15:0] <= config_data;               // put the refresh period value onto ADDR    
                cmd  <= 3'b111;                          // issue a load reg2 command 
                @(cmdack == 1 );                         // wait for an ack from the controller    
                #2; 
                cmd  <= 3'b000;                          // NOP 
                addr <= 0; 
                config_data <= 0;                
                 
                config_data[1:0] <= cl;                  // load controller reg1 
                config_data[3:2] <= rc; 
                config_data[8] <= pm; 
                config_data[12:9] <= bl/2; 
                @(posedge clk or negedge clk); 
                #2; 
                addr[15:0] <= config_data; 
                cmd  <= 3'b110;                          // issue load reg2 command 
                @(cmdack == 1)                           // wait for command ack from the controller 
                #2; 
                cmd  <= 3'b000;                          // NOP 
                addr <= 0; 
                config_data <= 0; 
         
                
                 
        end 
endtask 
 
initial begin 
        cmd <= 0; 
        addr <= 0; 
        ref_ack <= 0; 
        dm <= 0; 
 
        #3000;  
 
  bl = 1; 
   
   
 
  $display("Testing data mask inputs"); 
  config1(8,3,3,0,1526); 
  #1000; 
   
  $display("writing pattern 0,1,2,3,4,5,6,7 to sdram at address 0x0"); 
  burst_write(0, 0, 16'b0, 3, 4); 
   
  $display("Reading and verifing the pattern 0,1,2,3,4,5,6,7 at sdram address 0x0"); 
  burst_read(0, 0, 3, 3, 4); 
   
  $display("Writing pattern 0xfffffff0, 0xfffffff1, 0xfffffff2, 0xfffffff3, 0xfffffff4, 0xfffffff5, 0xfffffff6, 0xfffffff7"); 
  $display("with DM set to 0xf"); 
  burst_write(0, 32'hfffffff0, 16'hffff, 3, 4); 
   
  $display("Reading and verifing that the pattern at sdram address 0x0 is"); 
  $display("still 0,1,2,3,4,5,6,7"); 
  burst_read(0, 0, 3, 3, 4); 
   
  $display("End of data mask test"); 
   
 
 
 
 
   
  for (x = 1; x <=3; x = x + 1)                   // step through all burst lengths 
  begin 
    for (y = 2; y <= 4; y = y + 1)                // step through all cas latencies 
    begin 
      for (z = 2; z <=3; z = z + 1)               // step through all RC 
      begin 
          if (y == 1) 
             $display("configuring for bl = %d   cl = 1.5  rc = %d",bl,z); 
         else if (y==2) 
             $display("configuring for bl = %d   cl = 2.0   rc = %d",bl,z); 
         else if (y == 3) 
             $display("configuring for bl = %d   cl = 2.5   rc = %d",bl,z); 
         else 
             $display("configuring for bl = %d   cl = 3.0   rc = %d",bl,z); 
         config1(bl*2, y, z, 0, 1526); 
                 
 
// perform 1024 burst writes, writing a ramp pattern 
        $display("Peforming burst write to first sdram bank"); 
        test_data <= 0; 
        test_addr <= 0; 
        @(posedge clk or negedge clk); 
        @(posedge clk or negedge clk); 
        for (j = 0; j < `LOOP_LENGTH; j = j + 1) 
        begin 
                burst_write(test_addr, test_data, 4'h0, z, bl); 
                test_data <= test_data + bl; 
                test_addr <= test_addr + bl*2; 
                #50; 
        end 
         
 
// perform 1024 burst reads, verifing the ramp pattern 
        $display("Performing burst read, verify ramp values in first sdram bank"); 
        test_data <= 0; 
        test_addr <= 0; 
        @(posedge clk or negedge clk); 
        @(posedge clk or negedge clk); 
        for (j = 0; j < `LOOP_LENGTH; j = j + 1) 
        begin 
                burst_read(test_addr, test_data, y, z, bl); 
                test_data <= test_data + bl; 
                test_addr <= test_addr + bl*2; 
                @(posedge clk  or negedge clk); 
        end 
         
        #500; 
 
// perform 1024 burst writes, writing a ramp pattern 
        $display("Peforming burst write to second sdram bank"); 
        test_data <= 0; 
        test_addr <= 22'h200000; 
        @(posedge clk or negedge clk); 
        @(posedge clk or negedge clk); 
        for (j = 0; j < `LOOP_LENGTH; j = j + 1) 
        begin 
                burst_write(test_addr, test_data, 4'h0, z, bl); 
                test_data <= test_data + bl; 
                test_addr <= test_addr + bl*2; 
                @(posedge clk or negedge clk); 
        end 
         
// perform 1024 burst reads, verifing the ramp pattern 
        $display("Performing burst read, verify ramp values in second sdram bank"); 
        test_data <= 0; 
        test_addr <= 22'h200000; 
 
        @(posedge clk or negedge clk); 
        @(posedge clk or negedge clk); 
        for (j = 0; j < `LOOP_LENGTH; j = j + 1) 
        begin 
                burst_read(test_addr, test_data, y, z, bl); 
                test_data <= test_data + bl; 
                test_addr <= test_addr + bl*2; 
                @(posedge clk or negedge clk); 
        end 
         
        #500; 
 
        $display("Test complete"); 
      end 
    end 
    bl = bl * 2; 
	 
  end	 
$stop; 
end 
 
endmodule 
 

