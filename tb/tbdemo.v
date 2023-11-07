module tbdemo;

	reg clk;
	reg rst;
	wire[7:0] tb_led_o;
	
	
	
	always #10 clk = ~clk;
	
	initial begin
		clk <= 1'b1;
		rst <= 1'b0;
		#30;
		rst <= 1'b1;	
	end
	
	//rom 初始值
	/*initial begin
		$readmemh("C://Users//91904//Desktop//phase2_4opti//phase2_opti//tb//inst_txt//demo.txt",tbdemo.open_risc_v_soc_inst.rom_inst.rom_mem.dual_ram_template_inst.memory);
	end*/

	
	open_risc_v_soc open_risc_v_soc_inst(
		.clk   		(clk),
		.rst 		(rst),
		.led		(tb_led_o)
	);


	
endmodule