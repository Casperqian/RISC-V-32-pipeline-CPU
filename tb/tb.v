module tb;

	reg clk;
	reg rst;
	
	
	wire x3 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[3];
	wire x26 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[26];
	wire x27 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27];
	
	
	always #10 clk = ~clk;
	
	initial begin
		clk <= 1'b1;
		rst <= 1'b0;
		#30;
		rst <= 1'b1;	
	end
	
	//rom 初始值
	initial begin
		$readmemh("C://Users//91904//Desktop//phase2_4opti//phase2_opti//tb//inst_txt//rv32ui-p-sw.txt",tb.open_risc_v_soc_inst.rom_inst.rom_mem.dual_rom_template_inst.memory);
	end


	integer r;
	initial begin
/* 		while(1)begin
			@(posedge clk) 
			$display("x27 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[27]);
			$display("x28 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[28]);
			$display("x29 register value is %d",tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[29]);
			$display("---------------------------");
			$display("---------------------------");
		end */
		
		wait(x26 == 32'b1);
		
		#200;
		if(x27 == 32'b1) begin
			$display("############################");
			$display("########  pass  !!!#########");
			$display("############################");
		end
		else begin
			$display("############################");
			$display("########  fail  !!!#########");
			$display("############################");
			$display("fail testnum = %2d", x3);
			for(r = 0;r < 31; r = r + 1)begin
				$display("x%2d register value is %d",r,tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[r]);	
			end	
		end
	end
	
	open_risc_v_soc open_risc_v_soc_inst(
		.clk   		(clk),
		.rst 		(rst)
	);


	
endmodule