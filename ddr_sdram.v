module ddr_sdram( 
        CLK, 
        RESET_N, 
        ADDR, 
        CMD, 
        CMDACK, 
        DATAIN, 
        DATAOUT, 
        DM, 
        SA, 
        BA, 
        CS_N, 
        CKE, 
        RAS_N, 
        CAS_N, 
        WE_N, 
        DQ, 
        DQM, 
        DQS 
        ); 
 
 
`include        "params.v" 
`include        "pll1.v"
`include        "altclklock.v"
`include        "ddr_controle_interface.v"
`include        "ddr_commands.v"
`include        "ddr_data_path.v"

 
input                           CLK;                    //System Clock 
input                           RESET_N;                //System Reset 
input   [`ASIZE-1:0]            ADDR;                   //Address for controller requests 

input   [2:0]                   CMD;                    //Controller command  
output                          CMDACK;                 //Controller command acknowledgement 
input   [`DSIZE-1:0]            DATAIN;                 //Data input 
output  [`DSIZE-1:0]            DATAOUT;                //Data output 
input   [`DSIZE/8-1:0]          DM;                     //Data mask input 
output  [11:0]                  SA;                     //SDRAM address output 
output  [1:0]                   BA;                     //SDRAM bank address 
output  [1:0]                   CS_N;                   //SDRAM Chip Selects 
output                          CKE;                    //SDRAM clock enable 
output                          RAS_N;                  //SDRAM Row address Strobe 
output                          CAS_N;                  //SDRAM Column address Strobe 
output                          WE_N;                   //SDRAM write enable 
inout   [`DSIZE/2-1:0]          DQ;                     //SDRAM data bus 
output  [`DSIZE/16-1:0]         DQM;                    //SDRAM data mask lines 
inout   [`DSIZE/16-1:0]         DQS;                    //SDRAM Data Strobe lines 
 
reg     [11:0]                  SA;                     //SDRAM address output 
reg     [1:0]                   BA;                     //SDRAM bank address 
reg     [1:0]                   CS_N;                   //SDRAM Chip Selects 
reg                             CKE;                    //SDRAM clock enable 
reg                             RAS_N;                  //SDRAM Row address Strobe 
reg                             CAS_N;                  //SDRAM Column address Strobe 
reg                             WE_N;                   //SDRAM write enable 
 
reg     [`DSIZE/2-1:0]          DQIN; 
 
wire    [`DSIZE/2-1:0]          DQOUT; 
 
wire    [11:0]                  ISA;                     //SDRAM address output 
wire    [1:0]                   IBA;                     //SDRAM bank address 
wire    [1:0]                   ICS_N;                   //SDRAM Chip Selects 
wire                            ICKE;                    //SDRAM clock enable 
wire                            IRAS_N;                  //SDRAM Row address Strobe 
wire                            ICAS_N;                  //SDRAM Column address Strobe 
wire                            IWE_N;                   //SDRAM write enable 
 
wire    [`ASIZE-1:0]            saddr; 
wire    [1:0]                   sc_cl; 
wire    [1:0]                   sc_rc; 
wire    [3:0]                   sc_rrd; 
wire                            sc_pm; 
wire    [3:0]                   sc_bl; 
wire                            load_mode; 
wire                            nop; 
wire                            reada; 
wire                            writea; 
wire                            refresh; 
wire                            precharge; 
wire                            oe; 
wire                            CLK100; 
wire                            CLK200; 
wire                            locked; 
wire                            dqoe1; 
wire                            dqoe2; 
wire                            dqoe3; 
wire                            dqoe4; 
 
 
 
 
//initiate the pll 
pll1 PLL_1 ( 
                .inclock(CLK), 
                .clock0(CLK100), 
                .clock1(CLK200), 
                .locked(locked) 
                ); 
         
               
// instantiate block of the controller 
ddr_control_interface control1 ( 
                .CLK(CLK100), 
                .RESET_N(RESET_N), 
                .CMD(CMD), 
                .ADDR(ADDR), 
                .REF_ACK(ref_ack), 
                .CM_ACK(cm_ack), 
                .NOP(nop), 
                .READA(reada), 
                .WRITEA(writea), 
                .REFRESH(refresh), 
                .PRECHARGE(precharge), 
                .LOAD_MODE(load_mode), 
                .SADDR(saddr), 
                .SC_CL(sc_cl), 
                .SC_RC(sc_rc), 
                .SC_RRD(sc_rrd), 
                .SC_PM(sc_pm), 
                .SC_BL(sc_bl), 
                .REF_REQ(ref_req), 
                .CMD_ACK(CMDACK) 
                ); 
 
ddr_command command1( 
                .CLK(CLK100), 
                .RESET_N(RESET_N), 
                .SADDR(saddr), 
                .NOP(nop), 
                .READA(reada), 
                .WRITEA(writea), 
                .REFRESH(refresh), 
                .PRECHARGE(precharge), 
                .LOAD_MODE(load_mode), 
                .SC_CL(sc_cl), 
                .SC_RC(sc_rc), 
                .SC_RRD(sc_rrd), 
                .SC_PM(sc_pm), 
                .SC_BL(sc_bl), 
                .REF_REQ(ref_req), 
                .REF_ACK(ref_ack), 
                .CM_ACK(cm_ack), 
                .OE(oe), 
                .SA(ISA), 
                .BA(IBA), 
                .CS_N(ICS_N), 
                .CKE(ICKE), 
                .RAS_N(IRAS_N), 
                .CAS_N(ICAS_N), 
                .WE_N(IWE_N) 
                ); 
                 
ddr_data_path data_path1( 
                .CLK100(CLK100), 
                .CLK200(CLK200), 
                .RESET_N(RESET_N), 
                .OE(oe), 
                .DATAIN(DATAIN[31:0]), 
                .DM(DM[3:0]), 
                .DATAOUT(DATAOUT[31:0]), 
                .DQIN(DQIN[15:0]), 
                .DQOUT(DQOUT[15:0]), 
                .DQM(DQM[1:0]), 
                .DQS(DQS[1:0]), 
                .SC_CL(sc_cl), 
                .DQOE(dqoe1) 
                ); 
 
ddr_data_path data_path2( 
                .CLK100(CLK100), 
                .CLK200(CLK200), 
                .RESET_N(RESET_N), 
                .OE(oe), 
                .DATAIN(DATAIN[63:32]), 
                .DM(DM[7:4]), 
                .DATAOUT(DATAOUT[63:32]), 
                .DQIN(DQIN[31:16]), 
                .DQOUT(DQOUT[31:16]), 
                .DQM(DQM[3:2]), 
                .DQS(DQS[3:2]), 
                .SC_CL(sc_cl), 
                .DQOE(dqoe2) 
                ); 
 
ddr_data_path data_path3( 
                .CLK100(CLK100), 
                .CLK200(CLK200), 
                .RESET_N(RESET_N), 
                .OE(oe), 
                .DATAIN(DATAIN[95:64]), 
                .DM(DM[11:8]), 
                .DATAOUT(DATAOUT[95:64]), 
                .DQIN(DQIN[47:32]), 
                .DQOUT(DQOUT[47:32]), 
                .DQM(DQM[5:4]), 
                .DQS(DQS[5:4]), 
                .SC_CL(sc_cl), 
                .DQOE(dqoe3) 
                ); 
 
ddr_data_path data_path4( 
                .CLK100(CLK100), 
                .CLK200(CLK200), 
                .RESET_N(RESET_N), 
                .OE(oe), 
                .DATAIN(DATAIN[127:96]), 
                .DM(DM[15:12]), 
                .DATAOUT(DATAOUT[127:96]), 
                .DQIN(DQIN[63:48]), 
                .DQOUT(DQOUT[63:48]), 
                .DQM(DQM[7:6]), 
                .DQS(DQS[7:6]), 
                .SC_CL(sc_cl), 
                .DQOE(dqoe4) 
                ); 
 
 
// register the SDRAM i/o for higher performance. 
always @(posedge CLK100) 
begin 
                SA      <= ISA; 
                BA      <= IBA; 
                CS_N    <= ICS_N; 
                CKE     <= ICKE; 
                RAS_N   <= IRAS_N; 
                CAS_N   <= ICAS_N; 
                WE_N    <= IWE_N; 
end 
 
// capture the read data 
always @(negedge CLK200 or negedge RESET_N) 
begin 
     if (RESET_N == 0) 
          DQIN <= 0; 
     else 
          DQIN <= DQ; 
end 
 
assign  DQ[15:0]  = dqoe1 ? DQOUT[15:0]  : 16'bz;                      
assign  DQ[31:16] = dqoe2 ? DQOUT[31:16] : 16'bz;                      
assign  DQ[47:32] = dqoe3 ? DQOUT[47:32] : 16'bz;                      
assign  DQ[63:48] = dqoe4 ? DQOUT[63:48] : 16'bz;                      
 
endmodule 
 
