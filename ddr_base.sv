`ifndef _base_
`define _base_

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

class ddr_base;
  
rand bit  RESET_N;

rand bit   [`ASIZE-1:0]            ADDR;                   //Address for controller requests 
randc bit   [2:0]                  CMD;                    //Controller command  
bit                                CMDACK;                 //Controller command acknowledgement 
rand bit   [`DSIZE-1:0]            DATAIN;                 //Data rand bit 
bit        [`DSIZE-1:0]            DATAOUT;                //Data rand bit 
rand bit   [`DSIZE/8-1:0]          DM;                     //Data mask rand bit 
bit [127:0] DOUT;
bit        [11:0]                  SA;                     //SDRAM address rand bit 
bit        [1:0]                   BA;                     //SDRAM bank address 
bit        [1:0]                   CS_N;                   //SDRAM Chip Selects 
bit                                CKE;                    //SDRAM clock enable 
bit                                RAS_N;                  //SDRAM Row address Strobe 
bit                                CAS_N;                  //SDRAM Column address Strobe 
bit                                WE_N;                   //SDRAM write enable 
bit   [`DSIZE/2-1:0]               DQ;                     //SDRAM data bus
bit   [`DSIZE/16-1:0]              DQM;                    //SDRAM data mask lines 
bit   [`DSIZE/16-1:0]              DQS;

endclass

`endif


