module ctrl(
	input wire [31:0]jump_addr_i,
	input wire    	 jump_en_i,
	input wire   	 hold_flag_ex_i,
	
	output reg [31:0]jump_addr_o,
	output reg    	 jump_en_o,
	output reg   	 hold_flag_o	
);

	always @(*)begin
		jump_addr_o = jump_addr_i;
		jump_en_o   = jump_en_i; 
		if( jump_en_i || hold_flag_ex_i)begin 
			hold_flag_o = 1'b1;
		end
		else begin
			hold_flag_o = 1'b0;
		end
	end




endmodule