module open_risc_v_soc(
	input  wire 		  clk   		,
	input  wire 		  rst     		,
	output wire[7:0]	  led			
);
	//wire x3 = tb.open_risc_v_soc_inst.open_risc_v_inst.regs_inst.regs[3];
	wire x26 = open_risc_v_soc.open_risc_v_inst.regs_inst.regs[26];
	wire x27 = open_risc_v_soc.open_risc_v_inst.regs_inst.regs[27];
	
	// open_risc_v to rom 
	wire[31:0] open_risc_v_inst_addr_o;
	
	//rom to open_risc_v
	wire[31:0] rom_inst_o;
	
	// open_risc_v to ram
	wire       open_risc_v_mem_wr_req_o ;
	wire[3:0]  open_risc_v_mem_wr_sel_o ;
	wire[31:0] open_risc_v_mem_wr_addr_o;
	wire[31:0] open_risc_v_mem_wr_data_o;
	wire 	   open_risc_v_mem_rd_req_o ;
	wire[31:0] open_risc_v_mem_rd_addr_o;
	
	//ram to open_risc_v
	wire[31:0] ram_rd_data_o;
	
	led_check led_check_inst(
	.clk			(clk)		,
	.rst			(rst)		,
	.check_one		(x26)		,
	.check_two		(x27)		,
	.led            (led)
	);
	
	open_risc_v open_risc_v_inst(
	.clk  			    (clk  					), 
	.rst 				(rst					),
	.inst_i				(rom_inst_o				),
	.inst_addr_o		(open_risc_v_inst_addr_o),
	.mem_rd_req_o		(open_risc_v_mem_rd_req_o	),
	.mem_rd_addr_o		(open_risc_v_mem_rd_addr_o	),
	.mem_rd_data_i		(ram_rd_data_o				),
	.mem_wr_req_o		(open_risc_v_mem_wr_req_o	),
	.mem_wr_sel_o		(open_risc_v_mem_wr_sel_o	),
	.mem_wr_addr_o		(open_risc_v_mem_wr_addr_o	),
	.mem_wr_data_o		(open_risc_v_mem_wr_data_o	)
    );
	
	ram ram_inst(
		.clk		(clk								),
		.rst		(rst 								),
		.wen		(open_risc_v_mem_wr_sel_o			),//写端口
		.w_addr_i	(open_risc_v_mem_wr_addr_o			),
		.w_data_i	(open_risc_v_mem_wr_data_o			),
		.ren		(open_risc_v_mem_rd_req_o			),//读端口	
		.r_addr_i	(open_risc_v_mem_rd_addr_o			),
		.r_data_o	(ram_rd_data_o						)
	);



	rom rom_inst(
		.clk		(clk					 ),
		.rst		(rst					 ),	
		.wen		(1'b0		 			 ),//写端口  来自串口
		.w_addr_i	(32'b0 		 			 ),
		.w_data_i	(32'b0 		 			 ),
		.ren		(1'b1					 ),//指令读端口	
		.r_addr_i	(open_risc_v_inst_addr_o ),
		.r_data_o	(rom_inst_o				 )
	);
	
endmodule