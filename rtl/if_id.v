`include "defines.v"

module if_id(
	input wire clk,
	input wire rst,
	input wire hold_flag_i,
	input wire [31:0]  inst_i, 
	input wire [31:0]  inst_addr_i,
	output wire[31:0]  inst_addr_o, 
	output wire[31:0]  inst_o
);
	
	reg rom_flag;
	
	always @(posedge clk) begin
		if(!rst | hold_flag_i)
			rom_flag <= 1'b0;
		else
			rom_flag <= 1'b1;
	end
	
	assign inst_o = rom_flag ? inst_i : `INST_NOP;
	//dff_set #(32) dff1(clk,rst,hold_flag_i,`INST_NOP,inst_i,inst_o);
	
	dff_set #(32) dff2(clk,rst,hold_flag_i,32'b0,inst_addr_i,inst_addr_o);



endmodule

