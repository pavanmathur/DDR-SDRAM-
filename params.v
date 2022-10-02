/****************************************************************************** 
* 
*  LOGIC CORE:          SDRAM Controller - Global Constants							 
*  MODULE NAME:         params() 
*  COMPANY:             Northwest Logic Design, Inc. 
*                       www.nwlogic.com	 
* 
*  REVISION HISTORY:   
* 
*    Revision 1.0  05/12/2000 
*    Description: Initial Release. 
* 
* 
*  FUNCTIONAL DESCRIPTION: 
* 
*  This file defines a number of global constants used throughout 
*  the SDRAM Controller. 
*  Copyright Northwest Logic Design, Inc., 2000.  All rights reserved. 
******************************************************************************/ 
 
 
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
 