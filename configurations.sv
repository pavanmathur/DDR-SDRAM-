`ifndef _configurations_
`define _configurations_

class configurations;
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

  typedef enum {NOP,READA,WRITEA,REFRESH,PRECHARGE,LOAD_MODE,LOAD_REG2,LOAD_REG1} cmd1_type;
  typedef enum {random,constant,incremental,decremental,userpattern} addr_type;
  typedef enum {random1,constant1,incremental1,decremental1,userpattern1} data_type;
  typedef enum {random_dm,constant_dm,incremental_dm,decremental_dm,userpattern_dm} dm_type;
  typedef enum {random_dq,constant_dq,incremental_dq,decremental_dq,userpattern_dq} dq_type;
  typedef enum {random_dqs,constant_dqs,incremental_dqs,decremental_dqs,userpattern_dqs} dqs_type;
  typedef enum {random_cmd,constant_cmd,incremental_cmd,decremental_cmd,userpattern_cmd} cmd_type;
  
rand    cmd1_type    cmd1;
rand    addr_type   ADDR;
rand    data_type   DATAIN;
rand    dm_type     DM;
rand    dq_type     DQ;
rand    dqs_type    DQS;
rand    cmd_type    CMD;

int     num_txns;

rand bit  [`DSIZE-1:0]      TXDATAIN;
rand bit  [`ASIZE-1:0]      TXADDR;
randc bit [`DSIZE/8-1:0]    TXDM;
rand bit  [`DSIZE/2-1:0]    TXDQ;
rand bit  [`DSIZE/16-1:0]   TXDQS;
randc bit [2:0]             TXCMD;

logic     [`DSIZE-1:0]      user_DATAIN;// [8]='{100,200,25,35,45,55,65,75};
logic     [`ASIZE-1:0]      user_ADDR;// [8]='{06,16,26,36,46,56,66,76};
logic     [`DSIZE/8-1:0]    user_DM;// [8]='{15,12,10,5,6,8,2,3};
logic     [`DSIZE/2-1:0]    user_DQ;// [4]='{04,06,02,01};
logic     [`DSIZE/16-1:0]   user_DQS;// [8]='{15,20,06,07,10,40,30,33};
logic     [2:0]             user_CMD;// [8]='{0,1,2,3,4,5,6,7};

endclass	
`endif


