/****************************************************************************** 
* 
*  LOGIC CORE:          DDR Data Path Module							 
*  MODULE NAME:         ddr_data_path() 
*  COMPANY:             Northwest Logic Design, Inc.	 
* 
*  REVISION HISTORY:   
* 
*    Revision 1.0  05/12/2000	Description: Initial Release. 
* 
*  FUNCTIONAL DESCRIPTION: 
* 
*  This module is the top level module for the Local bus version of the 
*  SDRAM controller. 
* 
*  Copyright Northwest Logic Design, Inc., 2000.  All rights reserved. 
******************************************************************************/ 
module ddr_data_path( 
        CLK100, 
        CLK200, 
        RESET_N, 
        OE, 
        DATAIN, 
        DM, 
        DATAOUT, 
        DQIN, 
        DQOUT, 
        DQM, 
        DQS, 
        SC_CL, 
        DQOE 
        ); 
 

 
// Address Space Parameters 
 
`define ROWSTART        8            
`define ROWSIZE         12 
`define COLSTART        0 
`define COLSIZE         8 
`define BANKSTART       19 
`define BANKSIZE        2 
 
// Address and Data Bus Sizes 
 
`define ASIZE           22      // total address width of the SDRAM 
`define DSIZE         128       // Width of data bus to SDRAMS 
 

 
input                           CLK100;                 // System 1x Clock 
input                           CLK200;                 // System 2x clock 
input                           RESET_N;                // System Reset 
input                           OE;                     // Data output(to the SDRAM) enable 
input   [31:0]                  DATAIN;                 // Data input from the host 
input   [3:0]                   DM;                     // byte data masks 
output  [31:0]                  DATAOUT;                // Read data output to host 
input   [15:0]                  DQIN;                   // SDRAM data bus 
output  [15:0]                  DQOUT;                  // SDRAM data bus 
output  [1:0]                   DQM;                    // SDRAM data mask ouputs 
inout   [1:0]                   DQS;                    // SDRAM Data Strobe outputs 
input   [1:0]                   SC_CL;                  // Configured cas latency 
output                          DQOE; 
 
reg     [31:0]                  DATAOUT;                // User read data out 
reg     [1:0]                   DQM;                    // SDRAM DQM outputs 
wire    [1:0]                   DQS;                    // SDRAM DQS outputs 
 
 
// internal  
reg     [31:0]                  din1; 
reg     [31:0]                  din2; 
reg     [31:0]                  din2a; 
reg     [3:0]                   dmin1; 
reg     [3:0]                   dmin2; 
reg     [3:0]                   dmin2a; 
reg     [15:0]                  dq1; 
reg     [15:0]                  dq2; 
reg     [1:0]                   dm1; 
reg                             hi_lo; 
reg                             dqs1a; 
reg                             dqs2a; 
reg                             dqs3a; 
reg                             dqs1b; 
reg                             dqs2b; 
reg                             dqs3b; 
 
reg                             ioe; 
reg     [15:0]                  din2x_1; 
reg     [15:0]                  din2x_2; 
reg     [15:0]                  din1x_h1; 
reg     [15:0]                  din1x_l1; 
reg     [15:0]                  din1x_h2; 
reg     [15:0]                  din1x_l2; 
reg     [15:0]                  din1x_h3; 
reg     [15:0]                  din1x_l3; 
reg                             delayed_OE; 
reg                             dqs_oea; 
reg                             dqs_oeb; 
reg                             d2_OE; 
reg                             ioen; 
 
reg     [15:0]                  din2x_1a; 
 
 
 
 
//   This always block registers the write data from the user interface 
//   and prepares to transfer it over to the 2x clock domain. 
//   The always block also takes data from the read capture portion of this 
//   module and clocks it into the 1x clock domain, adjusting for cas latency. 
always @(posedge CLK100 or negedge RESET_N) 
begin 
        if (RESET_N == 0)  
        begin 
                din1     <= 0; 
                din2     <= 0; 
                dmin1    <= 0; 
                dmin2    <= 0; 
                din1x_l1 <= 0; 
                din1x_h2 <= 0; 
                din1x_l2 <= 0; 
                din1x_h3 <= 0; 
                din1x_l3 <= 0; 
                ioe <= 0; 
        end 
         
        else 
        begin 
               ioe <= OE; 
                din1      <= DATAIN;                   // Register the incoming data from the user 
                din2      <= din1; 
                dmin1     <= DM;                       // Register the incoming data mask from the user 
                dmin2     <= dmin1; 
                 
                din1x_l1  <= din2x_2;                  // Take the read data from the sdram, retiming it to 
                din1x_l2  <= din1x_l1;                 // the 1x clock domain 
                din1x_h2  <= din1x_h1; 
                 
                DATAOUT[15:0] <= din1x_l3;             // Put the read data out onto the DATAOUT port 
                DATAOUT[31:16] <= din1x_h3;             
                 
                if (SC_CL[0] == 0)                     // Adjust the incoming read data from the SDRAM devices 
                begin                                  // for the effects of cas latency 
                        din1x_h3 <= din1x_h2; 
                        din1x_l3 <= din1x_l2; 
                end 
                 
                else 
                begin 
                        din1x_h3 <= din1x_l1; 
                        din1x_l3 <= din1x_h2; 
                end 
        end 
end 
 
 
 
// This always block takes the user write data from the 1x clock domain, tranfers it to the 
// 2x clock domain and multiplexes down to half the data width(running at 2x the rate). 
always @(posedge CLK200 or negedge RESET_N) 
begin 
        if (RESET_N == 0)  
        begin 
                dq1   <= 0; 
                DQM   <= 0; 
                hi_lo <= 0; 
        end 
         
        else 
        begin 
                dq2 <= dq1;                            // pipeline the data 
                DQM  <= dm1;                           // send the data mask out 
                 
                din2a <= din2; 
                dmin2a <= dmin2; 
                 
                if (hi_lo == 1)                         // mux the write data 
                begin 
                        dq1 <= din2a[31:16]; 
                        dm1 <= dmin2a[3:2]; 
                end 
                else 
                begin 
                        dq1 <= din2a[15:0]; 
                        dm1 <= dmin2a[1:0]; 
                end         
                if (ioen == 1)                           // track whether to send out the high bits 
                        hi_lo <= !hi_lo;               // or the low. 
                else 
                        hi_lo <= 0; 
        end 
                         
end 
 
 
// This always block captures the read data from the SDRAM devices 
// and generates the DQS signal for write to SDRAM operations. 
always @(negedge CLK200 or negedge RESET_N) 
begin 
        if (RESET_N == 0)  
        begin 
                dqs1a      <= 0; 
                dqs2a      <= 0; 
                dqs1b      <= 0; 
                dqs2b      <= 0; 
                delayed_OE <= 0; 
                din2x_1    <= 0; 
                din2x_2    <= 0; 
                dqs_oea    <= 0; 
                dqs_oeb    <= 0; 
        end 
         
        else 
        begin 
                d2_OE <= OE; 
                delayed_OE <= d2_OE;                      // Generate versions of OE(from the controller) 
                if ((ioe == 1) & (d2_OE == 1))            // in order to control the tristate 
                    dqs_oea <= 1;                      // buffers for the DQS and DQ lines. 
                else 
                    dqs_oea <= 0; 
                if (d2_OE == 1) 
                    dqs2a <= dqs1a; 
 
                if ((ioe == 1) & (d2_OE == 1))   
                    dqs_oeb <= 1; 
                else 
                    dqs_oeb <= 0; 
                if (d2_OE == 1) 
                    dqs2b <= dqs1b; 
 
                if (delayed_OE == 1)                    // Generate DQS 
                begin 
                        dqs1a <= !dqs1a; 
                end 
                 
                else 
                begin 
                        dqs1a <= 0; 
                end 
 
 
 
 
 
                if (delayed_OE == 1)                    // Generate DQS 
                begin 
                        dqs1b <= !dqs1b; 
                end 
                 
                else 
                begin 
                        dqs1b <= 0; 
                end 
                 
                 
//                din2x_1 <= DQ; 
//                din2x_2 <= din2x_1; 
                din2x_2 <= DQIN; 
                 
        end 
end 
 
// delay OE for dq and dqs generation and move read data to clk100 domain 
always @(negedge CLK100 or negedge RESET_N) 
begin 
        if (RESET_N == 0)  
        begin 
                ioen      <= 0; 
                din1x_h1 <= 0; 
        end 
         
        else 
        begin 
                ioen <= OE;                      // delay OE 
                din1x_h1 <= din2x_2;            // demux data and bring it over to clk100 
        end 
end    
  
//assign  DQ = ioen ? dq2 : 16'bz;                      
assign  DQOUT = dq2;  
assign  DQOE  = ioen;  
assign  DQS[0] = dqs_oea ? dqs2a : 1'bz; 
assign  DQS[1] = dqs_oeb ? dqs2b : 1'bz; 
 
endmodule 
 
