`ifndef _intf_
`define _intf_
interface ddr_intf(input bit CLK , input bit RESET_N);
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

//ddr_sdram 

 wire    [`DSIZE/2-1:0]          DQ;
 wire    [`DSIZE/16-1:0]         DQS; 

logic   [`DSIZE/2-1:0]          DQ_drv;
logic   [`DSIZE/16-1:0]         DQS_drv;

//logic                           RESET_N;
logic   [`ASIZE-1:0]            ADDR;                   //Address for controller requests 
logic   [2:0]                   CMD;                    //Controller command  
logic                           CMDACK;                 //Controller command acknowledgement 
logic   [`DSIZE-1:0]            DATAIN;                 //Data logic 
logic  [`DSIZE-1:0]             DATAOUT;                //Data mask logic 
logic  [11:0]                   SA;                     //Data logic 
logic   [`DSIZE/8-1:0]          DM;                     //SDRAM address logic 
logic  [1:0]                    BA;                     //SDRAM bank address 
logic  [1:0]                    CS_N;                   //SDRAM Chip Selects 
logic                           CKE;                    //SDRAM clock enable 
logic                           RAS_N;                  //SDRAM Row address Strobe 
logic                           CAS_N;                  //SDRAM Column address Strobe 
logic                           WE_N;                   //SDRAM write enable 
logic  [`DSIZE/16-1:0]          DQM;                    //SDRAM data mask lines 
logic [127:0] DX;
clocking cb @(posedge CLK or negedge CLK or negedge RESET_N);
  default input#1 output #1;
//output                          CLK;                  
//output                          RESET_N;          
output                          ADDR;                  
output                          CMD;                 
input                           CMDACK;                  
output                          DATAIN;                
input                           DATAOUT; 
output                          DM;                   
input                           SA;                  
input                           BA;                   
input                           CS_N;                   
input                           CKE;                   
input                           RAS_N;                   
input                           CAS_N;                  
input                           WE_N;                   
input                          DQM; 

inout                           DQ;
inout                           DQS;                    
  
endclocking

assign DQ = DQ_drv;
assign DQS = DQS_drv;

                   
modport dut( inout DQ,inout DQS,input CLK,RESET_N,ADDR,CMD,DATAIN,DM,DQM,output CMDACK,SA,BA,CS_N,CKE,RAS_N,CAS_N,WE_N,DATAOUT,DX );
modport tb( input CLK,input RESET_N,clocking cb);
modport drv(inout DQ,DQS); 

endinterface

`endif


