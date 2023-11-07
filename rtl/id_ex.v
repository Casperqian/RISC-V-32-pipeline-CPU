`include "defines.v"

module id_ex(
	input wire clk					,
	input wire rst					,
	//from ctrl
	input wire hold_flag_i			,
	//from id
	input wire[31:0] inst_i			,
	input wire[31:0] inst_addr_i	,
	input wire[31:0] op1_i			,	
	input wire[31:0] op2_i			,
	input wire[4:0]  rd_addr_i		,	
	input wire 		 reg_wen_i		,
	input wire[31:0] base_addr_i	,
	input wire[31:0] addr_offset_i	,	
	//to ex
	output wire[31:0] inst_o		,
	output wire[31:0] inst_addr_o	,
	output wire[31:0] op1_o			,	
	output wire[31:0] op2_o			,
	output wire[4:0]  rd_addr_o		,	
	output wire 	  reg_wen_o		,	
	output wire[31:0] base_addr_o	,
	output wire[31:0] addr_offset_o		
);

	dff_set #(32) dff1(clk,rst,hold_flag_i,`INST_NOP,inst_i,inst_o);
	
	dff_set #(32) dff2(clk,rst,hold_flag_i,32'b0,inst_addr_i,inst_addr_o);
	
	dff_set #(32) dff3(clk,rst,hold_flag_i,32'b0,op1_i,op1_o);
	
	dff_set #(32) dff4(clk,rst,hold_flag_i,32'b0,op2_i,op2_o);
	
	dff_set #(5) dff5(clk,rst,hold_flag_i,5'b0,rd_addr_i,rd_addr_o);
	
	dff_set #(1) dff6(clk,rst,hold_flag_i,1'b0,reg_wen_i,reg_wen_o);
	
	dff_set #(32) dff7(clk,rst,hold_flag_i,32'b0,base_addr_i,base_addr_o);
	
	dff_set #(32) dff8(clk,rst,hold_flag_i,32'b0,addr_offset_i,addr_offset_o);





endmodule