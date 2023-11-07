module open_risc_v(
	input  wire 		  clk   		,
	input  wire 		  rst		    , 
	input  wire [31:0]    inst_i		,
	output wire [31:0]    inst_addr_o	,
	//read  mem
	output  wire 	   	  mem_rd_req_o		,
	output  wire [31:0]   mem_rd_addr_o		,
	input	wire [31:0]	  mem_rd_data_i		,	
	//write mem
	output  wire	 	  mem_wr_req_o		,
	output  wire  [3:0]   mem_wr_sel_o		,
	output  wire  [31:0]  mem_wr_addr_o		,
	output  wire  [31:0]  mem_wr_data_o		
);
	//pc to rom/if_id
	wire[31:0] pc_reg_pc_o;
	assign inst_addr_o = pc_reg_pc_o;
	// if_id to id
	wire[31:0] if_id_inst_addr_o;
	wire[31:0] if_id_inst_o;	
	
	//ex to regs
	wire[4:0]  ex_rd_addr_o;
	wire[31:0] ex_rd_data_o;
	wire       ex_reg_wen_o;

	//id to regs
	wire[4:0] id_rs1_addr_o;
	wire[4:0] id_rs2_addr_o;
	
	//id to id_ex
	wire[31:0] id_inst_o;
	wire[31:0] id_inst_addr_o;
	wire[31:0] id_op1_o;
	wire[31:0] id_op2_o;
	wire[4:0]  id_rd_addr_o;
	wire       id_reg_wen;
	wire[31:0] id_base_addr_o;	
	wire[31:0] id_addr_offset_o;	
	
	//regs to id
	wire[31:0] regs_reg1_rdata_o;
	wire[31:0] regs_reg2_rdata_o;
	
	
	//id_ex to ex
	wire[31:0] id_ex_inst_o;
	wire[31:0] id_ex_inst_addr_o;
	wire[31:0] id_ex_op1_o;
	wire[31:0] id_ex_op2_o;
	wire[4:0]  id_ex_rd_addr_o;
	wire       id_ex_reg_wen;
	wire[31:0] id_ex_base_addr_o;	
	wire[31:0] id_ex_addr_offset_o;
	
	//ex  to ctrl
	wire[31:0] ex_jump_addr_o;
	wire  	   ex_jump_en_o;
	wire 	   ex_hold_flag_o;
	//ctrl to pc_reg
	wire[31:0] ctrl_jump_addr_o;
	wire  	   ctrl_jump_en_o;
	//ctrl to if_id id_ex
	wire 	   ctrl_hold_flag_o;		
	
	
	pc_reg pc_reg_inst(
		.clk			(clk),
		.rst			(rst),
		.jump_addr_i	(ctrl_jump_addr_o), //&
		.jump_en		(ctrl_jump_en_o),		
		.pc_o   		(pc_reg_pc_o)
	);
	


	if_id if_id_inst(
		.clk			(clk		      ),
		.rst			(rst		      ),
		.hold_flag_i	(ctrl_hold_flag_o ),
		.inst_i			(inst_i 	      ),  
		.inst_addr_i	(pc_reg_pc_o   	  ),  
		.inst_addr_o	(if_id_inst_addr_o), 
		.inst_o         (if_id_inst_o	  )
	);
	

	
	id id_inst(
		.inst_i			(if_id_inst_o		),
		.inst_addr_i	(if_id_inst_addr_o	),
		.rs1_addr_o		(id_rs1_addr_o		),
		.rs2_addr_o		(id_rs2_addr_o		),
		.rs1_data_i		(regs_reg1_rdata_o	),
		.rs2_data_i		(regs_reg2_rdata_o	),
		.inst_o			(id_inst_o			),
		.inst_addr_o	(id_inst_addr_o		),	
		.op1_o			(id_op1_o			),	
		.op2_o			(id_op2_o			),
		.rd_addr_o		(id_rd_addr_o		),	
		.reg_wen        (id_reg_wen			),
		.base_addr_o	(id_base_addr_o		),
		.addr_offset_o	(id_addr_offset_o	),
		.mem_rd_req_o	(mem_rd_req_o		),
		.mem_rd_addr_o	(mem_rd_addr_o		)	
		);


	
	regs regs_inst(
		.clk			(clk					),
		.rst			(rst					),
		.reg1_raddr_i	(id_rs1_addr_o			),
		.reg2_raddr_i	(id_rs2_addr_o			), 
		.reg1_rdata_o	(regs_reg1_rdata_o		),
		.reg2_rdata_o	(regs_reg2_rdata_o		),
		.reg_waddr_i	(ex_rd_addr_o			),
		.reg_wdata_i	(ex_rd_data_o			),
		.reg_wen        (ex_reg_wen_o			)
	);
	

	id_ex id_ex_inst(
		.clk			(clk					),
		.rst			(rst					),
		.hold_flag_i	(ctrl_hold_flag_o 		),
		.inst_i			(id_inst_o				),
		.inst_addr_i	(id_inst_addr_o			),
		.op1_i			(id_op1_o				),
		.op2_i			(id_op2_o				),
		.rd_addr_i		(id_rd_addr_o			),
		.reg_wen_i		(id_reg_wen				),
		.base_addr_i	(id_base_addr_o			),
		.addr_offset_i	(id_addr_offset_o		),		
		.inst_o			(id_ex_inst_o			),
		.inst_addr_o    (id_ex_inst_addr_o		),
		.op1_o			(id_ex_op1_o			),
		.op2_o			(id_ex_op2_o			),
		.rd_addr_o		(id_ex_rd_addr_o		),
		.reg_wen_o		(id_ex_reg_wen			),
		.base_addr_o	(id_ex_base_addr_o		),
		.addr_offset_o	(id_ex_addr_offset_o	)		
		);
	


	ex ex_inst(
		.inst_i			(id_ex_inst_o			),	
		.inst_addr_i	(id_ex_inst_addr_o		),
		.op1_i			(id_ex_op1_o			),
		.op2_i			(id_ex_op2_o			),
		.rd_addr_i		(id_ex_rd_addr_o		),
		.rd_wen_i		(id_ex_reg_wen			),
		.base_addr_i	(id_ex_base_addr_o		),
		.addr_offset_i	(id_ex_addr_offset_o	),		
		.rd_addr_o		(ex_rd_addr_o			),
		.rd_data_o		(ex_rd_data_o			),	
		.rd_wen_o       (ex_reg_wen_o			),
		.jump_addr_o	(ex_jump_addr_o			),		
		.jump_en_o		(ex_jump_en_o			),		
		.hold_flag_o	(ex_hold_flag_o			),
		.mem_wr_req_o	(mem_wr_req_o		),
		.mem_wr_sel_o	(mem_wr_sel_o		),
		.mem_wr_addr_o	(mem_wr_addr_o		),
		.mem_wr_data_o	(mem_wr_data_o		),	
		.mem_rd_data_i	(mem_rd_data_i		)		
		
	);
	
	
	
	
	ctrl ctrl_inst(
		.jump_addr_i	(ex_jump_addr_o),
		.jump_en_i		(ex_jump_en_o),
		.hold_flag_ex_i	(ex_hold_flag_o),
		.jump_addr_o	(ctrl_jump_addr_o),
		.jump_en_o		(ctrl_jump_en_o),
		.hold_flag_o	(ctrl_hold_flag_o)	
	);

endmodule