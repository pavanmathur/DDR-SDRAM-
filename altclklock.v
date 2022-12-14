 module altclklock ( 
	inclock, 
//	inclocken, 
//	fbin, 
	locked, 
	clock0, 
	clock1); 
 
/* synthesis black_box */ 
 
	input	  inclock; 
//	input	  inclocken; 
//	input	  fbin; 
	output	  locked; 
	output	  clock0; 
	output	  clock1; 
 
/* synopsys translate_off*/ 
 
  
parameter inclock_period=10000; 
parameter inclock_settings = "UNUSED"; 
parameter valid_lock_cycles = 3; 
parameter invalid_lock_cycles = 3; 
parameter valid_lock_multiplier = 1; 
parameter invalid_lock_multiplier = 1; 
parameter operation_mode = "NORMAL"; 
parameter clock0_boost = 1; 
parameter clock0_divide = 1; 
parameter clock1_boost = 2; 
parameter clock1_divide = 1; 
parameter clock0_settings = "UNUSED"; 
parameter clock1_settings = "UNUSED"; 
parameter outclock_phase_shift = 0; 
 
 
 
 
reg clock0, clock1, locked; 
reg new_clock0, new_clock1, locked_int; 
reg start_new_clock0, start_new_clock1, outclock_start_edge; 
reg first_clock0_cycle, first_clock1_cycle; 
reg prev_inclock; 
wire inclocken; 
// internal reg 
 
integer pll0_half_period, pll1_half_period, phase_delay0, phase_delay1; 
integer inclock_edge_count; 
real lowcycle, highcycle; 
reg  cycleviolation; 
 
 
initial 
begin 
  locked_int = 0; 
  inclock_edge_count = 0; 
  first_clock0_cycle = 1; 
  first_clock1_cycle = 1; 
  lowcycle = 0; 
  highcycle = 0; 
  cycleviolation = 0; 
end 
    
assign inclocken = 1;   
always @ (inclock /*or inclocken*/) 
begin 
   if (locked_int == 0) begin 
      pll0_half_period = (inclock_period * clock0_divide)/(2 * clock0_boost); 
      pll1_half_period = (inclock_period * clock1_divide)/(2 * clock1_boost); 
//      if (outclock_phase_shift < 180.000) begin 
         outclock_start_edge = 1;  
//         phase_delay0 = (0.500 - (outclock_phase_shift/360.000)) * (2.000 * pll0_half_period); 
//         phase_delay1 = (0.500 - (outclock_phase_shift/360.000)) * (2.000 * pll1_half_period); 
//     end 
 
//      else if (outclock_phase_shift == 180.000) begin 
//         outclock_start_edge = 0; 
//         phase_delay0 = (outclock_phase_shift/360.000) * (2.000 * pll0_half_period); 
 //        phase_delay1 = (outclock_phase_shift/360.000) * (2.000 * pll1_half_period); 
  //    end 
  
   //   else begin 
    //     outclock_start_edge = 0;  
     //    phase_delay0 = ((outclock_phase_shift/360.000) - 0.500) * (2.000 * pll0_half_period); 
      //   phase_delay1 = ((outclock_phase_shift/360.000) - 0.500) * (2.000 * pll1_half_period); 
    
   //   end 
      phase_delay0 = outclock_phase_shift; 
      phase_delay1 = outclock_phase_shift; 
      start_new_clock0 = outclock_start_edge; 
      start_new_clock1 = !outclock_start_edge; 
   end 
       
   if ((inclocken == 0) || (cycleviolation == 1)) begin 
      inclock_edge_count = 0; 
      locked_int = 0; 
      locked = 0; 
   end 
   else if  (inclock != prev_inclock) begin // inclock edge detected 
      if (inclock == 1) begin 
         if (($realtime - lowcycle) != (inclock_period/2)) begin 
            $display ($time, "Error: Duty Cycle violation"); 
            cycleviolation = 1; 
         end 
         highcycle = $realtime; 
      end 
      if (inclock == 0) begin 
         if (($realtime - highcycle) != (inclock_period/2)) begin 
            $display ($time, "Error: Duty Cycle violation"); 
            cycleviolation = 1; 
         end 
         lowcycle = $realtime; 
      end 
      inclock_edge_count = inclock_edge_count + 1;  
      if (inclock_edge_count == valid_lock_cycles) begin 
         cycleviolation = 0; 
         locked_int = 1; 
         locked = 1; 
      end 
   end 
 
	prev_inclock = inclock; 
end 
 
always @ (new_clock0 or locked_int) 
begin 
      if (locked_int == 1) begin 
         if (first_clock0_cycle == 1) begin 
            clock0 = start_new_clock0; 
             # phase_delay0 new_clock0 <= ~start_new_clock0 ; 
         end 
         else begin 
            clock0 = new_clock0;  
            # (pll0_half_period) new_clock0 <= ~new_clock0 ; 
         end 
         first_clock0_cycle = 0; 
      end 
      else begin 
         first_clock0_cycle = 1; 
      end 
end 
 
always @ (new_clock1 or locked_int) 
begin 
      if (locked_int == 1) begin 
         if (first_clock1_cycle == 1) begin 
            clock1 = start_new_clock1; 
            #phase_delay1 new_clock1 <= ~start_new_clock1 ; 
         end 
         else begin 
            clock1 = new_clock1;  
            # (pll1_half_period) new_clock1 <= ~new_clock1 ; 
         end 
         first_clock1_cycle = 0; 
      end 
      else begin 
         first_clock1_cycle = 1; 
      end 
end 
//synopsys translate_on 
endmodule 
 
 
 
 
 
 
 
 
 
 
 
 
 
/* 
	wire  sub_wire0; 
	wire  sub_wire1; 
	wire  sub_wire2; 
	wire  clock0 = sub_wire0; 
	wire  clock1 = sub_wire1; 
	wire  locked = sub_wire2; 
 
	altclklock	altclklock_component ( 
				.fbin (fbin), 
				.inclocken (inclocken), 
				.inclock (inclock), 
				.clock0 (sub_wire0), 
				.clock1 (sub_wire1), 
				.locked (sub_wire2)); 
	defparam 
		altclklock_component.inclock_period = 40000, 
		altclklock_component.clock0_boost = 1, 
		altclklock_component.clock1_boost = 1, 
		altclklock_component.operation_mode = "EXTERNAL_FEEDBACK", 
		altclklock_component.valid_lock_cycles = 5, 
		altclklock_component.invalid_lock_cycles = 5, 
		altclklock_component.valid_lock_multiplier = 5, 
		altclklock_component.invalid_lock_multiplier = 5, 
		altclklock_component.clock0_divide = 1, 
		altclklock_component.clock1_divide = 1; 
*/ 
 
 
 
// ============================================================ 
// CNX file retrieval info 
// ============================================================ 
// Retrieval info: PRIVATE: DISPLAY_FREQUENCY STRING "25.0" 
// Retrieval info: PRIVATE: USING_FREQUENCY NUMERIC "0" 
// Retrieval info: PRIVATE: DEVICE_FAMILY NUMERIC "1" 
// Retrieval info: PRIVATE: FEEDBACK_SOURCE NUMERIC "1" 
// Retrieval info: PRIVATE: PHASE_UNIT NUMERIC "0" 
// Retrieval info: PRIVATE: USING_PROGRAMMABLE_PHASE_SHIFT NUMERIC "0" 
// Retrieval info: CONSTANT: INCLOCK_PERIOD NUMERIC "40000" 
// Retrieval info: CONSTANT: CLOCK0_BOOST NUMERIC "1" 
// Retrieval info: CONSTANT: CLOCK1_BOOST NUMERIC "1" 
// Retrieval info: CONSTANT: OPERATION_MODE STRING "EXTERNAL_FEEDBACK" 
// Retrieval info: CONSTANT: VALID_LOCK_CYCLES NUMERIC "5" 
// Retrieval info: CONSTANT: INVALID_LOCK_CYCLES NUMERIC "5" 
// Retrieval info: CONSTANT: VALID_LOCK_MULTIPLIER NUMERIC "5" 
// Retrieval info: CONSTANT: INVALID_LOCK_MULTIPLIER NUMERIC "5" 
// Retrieval info: CONSTANT: CLOCK0_DIVIDE NUMERIC "1" 
// Retrieval info: CONSTANT: CLOCK1_DIVIDE NUMERIC "1" 
// Retrieval info: USED_PORT: inclock 0 0 0 0 INPUT NODEFVAL inclock 
// Retrieval info: USED_PORT: locked 0 0 0 0 OUTPUT NODEFVAL locked 
// Retrieval info: USED_PORT: inclocken 0 0 0 0 INPUT NODEFVAL inclocken 
// Retrieval info: USED_PORT: fbin 0 0 0 0 INPUT NODEFVAL fbin 
// Retrieval info: USED_PORT: clock0 0 0 0 0 OUTPUT NODEFVAL clock0 
// Retrieval info: USED_PORT: clock1 0 0 0 0 OUTPUT NODEFVAL clock1 
// Retrieval info: CONNECT: @inclock 0 0 0 0 inclock 0 0 0 0 
// Retrieval info: CONNECT: locked 0 0 0 0 @locked 0 0 0 0 
// Retrieval info: CONNECT: @inclocken 0 0 0 0 inclocken 0 0 0 0 
// Retrieval info: CONNECT: @fbin 0 0 0 0 fbin 0 0 0 0 
// Retrieval info: CONNECT: clock0 0 0 0 0 @clock0 0 0 0 0 
// Retrieval info: CONNECT: clock1 0 0 0 0 @clock1 0 0 0 0 

