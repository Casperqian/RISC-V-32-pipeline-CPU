module rom(
	input  wire 		  clk		,
	input  wire 		  rst		,
	input  wire 		  wen		,//写端口
	input  wire[32-1:0]   w_addr_i	,
	input  wire[32-1:0]   w_data_i	,
	input  wire 		  ren		,//读端口	
	input  wire[32-1:0]   r_addr_i	,
	output wire[32-1:0]   r_data_o	
);
	wire[11:0] w_addr = w_addr_i[13:2];
	wire[11:0] r_addr = r_addr_i[13:2];

	dual_ram #(
		 .DW(32),
		 .AW(12),
		 .MEM_NUM(4096)
	)
	rom_mem
	(
       .clk		 	(clk        	),
	   .rst		 	(rst        	),
       .wen		 	(wen 	   		),
	   .w_addr_i 	(w_addr 		),
	   .w_data_i 	(w_data_i 	    ),
	   .ren		 	(ren			),
	   .r_addr_i 	(r_addr 		),
	   .r_data_o 	(r_data_o 	    )
	);

endmodule