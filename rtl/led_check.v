module led_check(
	input wire clk,
	input wire rst,
	input wire check_one,
	input wire check_two,
	output reg[7:0] led
);

	always @(posedge clk)begin
		if(rst == 1'b0)
			led <= 8'b0000_0000;
		else
			if (check_one == 1'b1 && check_two == 1'b1)
				led <= 8'b0000_0111;
			else if (check_one == 1'b1 && check_two == 1'b0)
				led <= 8'b0000_0011;
			else
				led <= 8'b0000_0001;
				
			
	end	

endmodule