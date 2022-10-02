/****************************************************************************** 
* 
*  LOGIC CORE:          DDR Command module							 
*  MODULE NAME:         ddr_command() 
*  COMPANY:             Northwest Logic Design, Inc.	 
*                       www.nwlogic.com 
* 
*  REVISION HISTORY:   
* 
*    Revision 1.0  05/12/2000	Description: Initial Release. 
* 
*  FUNCTIONAL DESCRIPTION: 
* 
*  This module is the command processor module for the DDR SDRAM controller. 
* 
*  Copyright Northwest Logic Design, Inc., 2000.  All rights reserved. 
******************************************************************************/ 
module ddr_command( 
        CLK, 
        RESET_N, 
        SADDR, 
        NOP, 
        READA, 
        WRITEA, 
        REFRESH, 
        PRECHARGE, 
        LOAD_MODE, 
        SC_CL, 
        SC_RC, 
        SC_RRD, 
        SC_PM, 
        SC_BL, 
        REF_REQ, 
        REF_ACK, 
        CM_ACK, 
        OE, 
        SA, 
        BA, 
        CS_N, 
        CKE, 
        RAS_N, 
        CAS_N, 
        WE_N 
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
 

 
input                           CLK;                    // System Clock 
input                           RESET_N;                // System Reset 
input   [`ASIZE-1:0]            SADDR;                  // Address 
input                           NOP;                    // Decoded NOP command 
input                           READA;                  // Decoded READA command 
input                           WRITEA;                 // Decoded WRITEA command 
input                           REFRESH;                // Decoded REFRESH command 
input                           PRECHARGE;              // Decoded PRECHARGE command 
input                           LOAD_MODE;              // Decoded LOAD_MODE command 
input   [1:0]                   SC_CL;                  // Programmed CAS latency 
input   [1:0]                   SC_RC;                  // Programmed RC delay 
input   [3:0]                   SC_RRD;                 // Programmed RRD delay 
input                           SC_PM;                  // programmed Page Mode 
input   [3:0]                   SC_BL;                  // Programmed burst length 
input                           REF_REQ;                // Hidden refresh request 
output                          REF_ACK;                // Refresh request acknowledge 
output                          CM_ACK;                 // Command acknowledge 
output                          OE;                     // OE signal for data path module 
output  [11:0]                  SA;                     // SDRAM address 
output  [1:0]                   BA;                     // SDRAM bank address 
output  [1:0]                   CS_N;                   // SDRAM chip selects 
output                          CKE;                    // SDRAM clock enable 
output                          RAS_N;                  // SDRAM RAS 
output                          CAS_N;                  // SDRAM CAS 
output                          WE_N;                   // SDRAM write enable 
 
             
reg                             CM_ACK; 
reg                             REF_ACK; 
reg                             OE/* synthesis syn_maxfan=1*/; 
reg     [11:0]                  SA; 
reg     [1:0]                   BA; 
reg     [1:0]                   CS_N; 
reg                             CKE; 
reg                             RAS_N; 
reg                             CAS_N; 
reg                             WE_N; 
 
 
 
// Internal signals 
reg                             do_nop; 
reg                             do_reada; 
reg                             do_writea; 
reg                             do_writea1; 
reg                             do_refresh; 
reg                             do_precharge; 
reg                             do_load_mode; 
reg                             command_done; 
reg     [7:0]                   command_delay; 
reg     [3:0]                   rw_shift; 
reg                             do_act; 
reg                             rw_flag; 
reg                             do_rw; 
reg     [7:0]                   oe_shift; 
reg                             oe1; 
reg                             oe2; 
reg                             oe3; 
reg                             oe4; 
reg     [3:0]                   rp_shift; 
reg                             rp_done; 
 
wire    [`ROWSIZE - 1:0]        rowaddr; 
wire    [`COLSIZE - 1:0]        coladdr; 
wire    [`BANKSIZE - 1:0]       bankaddr; 
 
assign	rowaddr   = SADDR[`ROWSTART + `ROWSIZE - 1: `ROWSTART];     // assignment of the row address bits from SADDR 
assign	coladdr   = SADDR[`COLSTART + `COLSIZE - 1:`COLSTART];      // assignment of the column address bits 
assign	bankaddr  = SADDR[`BANKSTART + `BANKSIZE - 1:`BANKSTART];   // assignment of the bank address bits 
 
 
// This always block monitors the individual command lines and issues a command 
// to the next stage if there currently another command already running. 
// 
 
always @(posedge CLK or negedge RESET_N) 
begin 
        if (RESET_N == 0)  
        begin 
                do_nop          <= 0; 
                do_reada        <= 0; 
                do_writea       <= 0; 
			 do_writea1      <= 0; 
                do_refresh      <= 0; 
                do_precharge    <= 0; 
                do_load_mode    <= 0; 
                command_done    <= 0; 
                command_delay   <= 0; 
                rw_flag         <= 0; 
                rp_shift        <= 0; 
                rp_done         <= 0; 
        end 
         
        else 
        begin 
 
//  Issue the appropriate command if the sdram is not currently busy      
                if ((REF_REQ == 1 | REFRESH == 1) & command_done == 0 & do_refresh == 0 & rp_done == 0        //Refresh 
                        & do_reada == 0 & do_writea == 0) 
                        do_refresh <= 1; 
                else 
                        do_refresh <= 0; 
                        
 
                if ((READA == 1) & (command_done == 0) & (do_reada == 0) & (rp_done == 0) & (REF_REQ == 0))   // READA 
                        do_reada <= 1; 
                else 
                        do_reada <= 0; 
                     
                if ((WRITEA == 1) & (command_done == 0) & (do_writea == 0) & (rp_done == 0) & (REF_REQ == 0)) //WRITEA 
                begin 
                        do_writea <= 1; 
                        do_writea1 <= 1; 
                end 
                else 
                begin 
                        do_writea <= 0; 
                        do_writea1 <= 0; 
                end 
                if ((PRECHARGE == 1) & (command_done == 0) & (do_precharge == 0))         // Precharge 
                        do_precharge <= 1; 
                else 
                        do_precharge <= 0; 
  
                if ((LOAD_MODE == 1) & (command_done == 0) & (do_load_mode == 0))         // load_mode 
                        do_load_mode <= 1; 
                else 
                        do_load_mode <= 0; 
                                                
// set command_delay shift register and command_done flag 
// The command delay shift register is a timer that is used to ensure that 
// the SDRAM devices have had sufficient time to finish the last command. 
 
                if ((do_refresh == 1) | (do_reada == 1) | (do_writea == 1) | (do_precharge == 1) 
                     | (do_load_mode)) 
                begin 
                        command_delay <= 8'b11111111; 
                        command_done  <= 1; 
                        rw_flag <= do_reada;                                                   
 
                end 
                 
                else 
                begin 
                        command_done        <= command_delay[0];            // the command_delay shift operation 
                        command_delay[6:0]  <= command_delay[7:1];                                 
                        command_delay[7]    <= 0; 
                end  
                 
 // start additional timer that is used for the refresh, writea, reada commands                
                 
                if (command_delay[0] == 0 & command_done == 1) 
                begin 
                        rp_shift <= 4'b1111; 
                        rp_done <= 1; 
                end 
                else 
                begin 
                        rp_done         <= rp_shift[0]; 
                        rp_shift[2:0]   <= rp_shift[3:1]; 
                        rp_shift[3]     <= 0; 
                end 
        end 
end 
 
// logic that generates the OE signal for the data path module 
// For normal burst write he duration of OE is dependent on the configured burst length. 
// For page mode accesses(SC_PM=1) the OE signal is turned on at the start of the write command 
// and is left on until a PRECHARGE(page burst terminate) is detected. 
// 
always @(posedge CLK or negedge RESET_N) 
begin 
        if (RESET_N == 0) 
        begin 
                oe_shift <= 0; 
                oe1      <= 0; 
                oe2      <= 0; 
                OE       <= 0; 
        end 
        else 
        begin 
                if (do_writea1 == 1) 
                begin 
                        if (SC_BL == 1)                          //  Set the shift register to the appropriate 
                                oe_shift <= 1;                   // value based on burst length. 
                        else if (SC_BL == 2) 
                                oe_shift <= 3; 
                        else if (SC_BL == 4) 
                                oe_shift <= 15; 
                                oe1 <= 1; 
                end 
                else  
                begin 
                        oe_shift[6:0] <= oe_shift[7:1];          // Do the shift operation 
                        oe_shift[7]   <= 0; 
                        oe1  <= oe_shift[0]; 
                        oe2  <= oe1; 
                        oe3  <= oe2; 
                        oe4  <= oe3; 
                        if (SC_RC == 2) 
                                OE   <= oe3; 
                        else 
                                OE   <= oe4; 
                end 
        end 
end 
 
 
 
 
// This always block tracks the time between the activate command and the 
// subsequent WRITEA or READA command, RC.  The shift register is set using 
// the configuration register setting SC_RC. The shift register is loaded with 
// a single '1' with the position within the register dependent on SC_RC. 
// When the '1' is shifted out of the register it sets so_rw which triggers 
// a writea or reada command 
// 
 
always @(posedge CLK or negedge RESET_N) 
begin 
        if (RESET_N == 0) 
        begin 
                rw_shift <= 0; 
                do_rw    <= 0; 
        end 
         
        else 
        begin 
                 
                if ((do_reada == 1) | (do_writea == 1)) 
                begin 
                        if (SC_RC == 1)                               // Set the shift register 
                                do_rw <= 1; 
                        else if (SC_RC == 2) 
                                rw_shift <= 1; 
                        else if (SC_RC == 3) 
                                rw_shift <= 2; 
                end 
                else 
                begin 
                        rw_shift[2:0] <= rw_shift[3:1];               // perform the shift operation 
                        rw_shift[3]   <= 0; 
                        do_rw         <= rw_shift[0]; 
                end  
        end 
end               
 
// This always block generates the command acknowledge, CM_ACK, signal. 
// It also generates the acknowledge signal, REF_ACK, that acknowledges 
// a refresh request that was generated by the internal refresh timer circuit. 
always @(posedge CLK or negedge RESET_N)  
begin 
 
        if (RESET_N == 0)  
        begin 
                CM_ACK   <= 0; 
                REF_ACK  <= 0; 
        end 
         
        else 
        begin 
                if (do_refresh == 1 & REF_REQ == 1)              // Internal refresh timer refresh request 
                        REF_ACK <= 1; 
                else if ((do_refresh == 1) | (do_reada == 1) | (do_writea == 1) | (do_precharge == 1)    // externa  commands 
                         | (do_load_mode)) 
                        CM_ACK <= 1; 
                else 
                begin 
                        REF_ACK <= 0; 
                        CM_ACK  <= 0; 
                end 
        end 
end  
                     
 
 
 
// This always block generates the address, cs, cke, and command signals(ras,cas,wen) 
//  
 
        always @(posedge CLK ) begin 
                if (RESET_N==0) begin 
                        SA    <= 0; 
                        BA    <= 0; 
                        CS_N  <= 1; 
                        RAS_N <= 1; 
                        CAS_N <= 1; 
                        WE_N  <= 1; 
                        CKE   <= 0; 
                end	 
                else begin 
                        CKE <= 1; 
 
// Generate SA 			 
                        if (do_writea == 1 | do_reada == 1)    // ACTIVATE command is being issued, so present the row address 
			 
                                SA <= rowaddr; 
                        else 
                                SA <= coladdr;              // else alway present column address 
                        if ((do_rw==1) | (do_precharge==1)) 
                                SA[10] <= !SC_PM;           // set SA[10] for autoprecharge read/write or for a precharge all command 
                                	                         // don't set it if the controller is in page mode.   
                        if (do_precharge==1 | do_load_mode==1) 
                                BA <= 0;                         // Set BA=0 if performing a precharge or load_mode command 
                        else 
                                BA <= bankaddr[1:0];             // else set it with the appropriate address bits 
				 
                        if (do_refresh==1 | do_precharge==1 | do_load_mode==1) 
                                CS_N <= 0;                       // Select both chip selects if performing 
                        else                                     // refresh, precharge(all) or load_mode 
                        begin 
                                CS_N[0] <= SADDR[`ASIZE-1];      // else set the chip selects based off of the 
                                CS_N[1] <= ~SADDR[`ASIZE-1];     // msb address bit 
                        end	 
 
//Generate the appropriate logic levels on RAS_N, CAS_N, and WE_N 
//depending on the issued command. 
//				 
				 
                        if (do_refresh==1) begin                        // Refresh: S=00, RAS=0, CAS=0, WE=1 
                                RAS_N <= 0; 
                                CAS_N <= 0; 
                                WE_N  <= 1; 
                        end 
                        else if (do_precharge==1) begin                 // Precharge All: S=00, RAS=0, CAS=1, WE=0 
                                RAS_N <= 0; 
                                CAS_N <= 1; 
                                WE_N  <= 0; 
                        end 
                        else if (do_load_mode==1) begin                 // Mode Write: S=00, RAS=0, CAS=0, WE=0 
                                RAS_N <= 0; 
                                CAS_N <= 0; 
                                WE_N  <= 0; 
                        end 
                        else if (do_reada == 1 | do_writea == 1) begin  // Activate: S=01 or 10, RAS=0, CAS=1, WE=1 
                                RAS_N <= 0; 
                                CAS_N <= 1; 
                                WE_N  <= 1; 
                        end 
                        else if (do_rw == 1) begin                      // Read/Write:	S=01 or 10, RAS=1, CAS=0, WE=0 or 1 
                                RAS_N <= 1; 
                                CAS_N <= 0; 
                                WE_N  <= rw_flag; 
                        end 
                        else begin                                      // No Operation: RAS=1, CAS=1, WE=1 
                                RAS_N <= 1; 
                                CAS_N <= 1; 
                                WE_N  <= 1; 
                        end 
                end  
        end 
 
 
 
 
endmodule 
