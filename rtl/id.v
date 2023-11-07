
`include "defines.v"

module id(
	//from if_id
	input wire[31:0] inst_i			,
	input wire[31:0] inst_addr_i	,
		
	// to regs 
	output reg[4:0] rs1_addr_o		,
	output reg[4:0] rs2_addr_o		,
	// from regs
	input wire[31:0] rs1_data_i		,
	input wire[31:0] rs2_data_i		,
	
	//to id_ex
	output reg[31:0] inst_o			,
	output reg[31:0] inst_addr_o	,
	output reg[31:0] op1_o			,	
	output reg[31:0] op2_o			,
	output reg[4:0]  rd_addr_o		,	
	output reg 		 reg_wen		,
	output reg[31:0] base_addr_o	,
	output reg[31:0] addr_offset_o	,
	//to ram_mem
	output reg		 mem_rd_req_o	,
	output reg[31:0] mem_rd_addr_o	
);

	wire[6:0] opcode; 
	wire[4:0] rd; 
	wire[2:0] func3; 
	wire[4:0] rs1;
	wire[4:0] rs2;
	wire[6:0] func7;
	wire[11:0]imm;
	wire[4:0] shamt;
	
	assign opcode = inst_i[6:0];
	assign rd 	  = inst_i[11:7];
	assign func3  = inst_i[14:12];
	assign rs1 	  = inst_i[19:15];
	assign rs2 	  = inst_i[24:20];
	assign func7  = inst_i[31:25];
	assign imm    = inst_i[31:20];
	assign shamt  = inst_i[24:20];
	

	
	
	
	always @(*)begin
		inst_o  	= inst_i;
		inst_addr_o = inst_addr_i;  
		
		case(opcode)
			`INST_TYPE_I:begin
				base_addr_o		= 32'b0;
				addr_offset_o	= 32'b0;
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				case(func3)
					`INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI:begin
						rs1_addr_o = rs1;
						rs2_addr_o = 5'b0;
						op1_o 	   = rs1_data_i;
						op2_o      = {{20{imm[11]}},imm};
						rd_addr_o  = rd;
						reg_wen    = 1'b1;
					end
					`INST_SLLI,`INST_SRI:begin
						rs1_addr_o = rs1;
						rs2_addr_o = 5'b0;
						op1_o 	   = rs1_data_i;
						op2_o      = {27'b0,shamt};
						rd_addr_o  = rd;
						reg_wen    = 1'b1;					
					end
					default:begin
						rs1_addr_o = 5'b0;
						rs2_addr_o = 5'b0;
						op1_o 	   = 32'b0;
						op2_o      = 32'b0;
						rd_addr_o  = 5'b0;
						reg_wen    = 1'b0;						
					end
				endcase	
			end
			`INST_TYPE_R_M:begin
				base_addr_o		= 32'b0;
				addr_offset_o	= 32'b0;
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				case(func3)
					`INST_ADD_SUB,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_OR,`INST_AND:begin
						rs1_addr_o = rs1;
						rs2_addr_o = rs2;
						op1_o 	   = rs1_data_i;
						op2_o      = rs2_data_i;
						rd_addr_o  = rd;
						reg_wen    = 1'b1;
					end
					`INST_SLL,`INST_SR:begin
						rs1_addr_o = rs1;
						rs2_addr_o = rs2;
						op1_o 	   = rs1_data_i;
						op2_o      = {27'b0,rs2_data_i[4:0]};
						rd_addr_o  = rd;
						reg_wen    = 1'b1;					
					end
					default:begin
						rs1_addr_o = 5'b0;
						rs2_addr_o = 5'b0;
						op1_o 	   = 32'b0;
						op2_o      = 32'b0;
						rd_addr_o  = 5'b0;
						reg_wen    = 1'b0;						
					end
				endcase				
			end
			`INST_TYPE_B:begin
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				case(func3)
					`INST_BNE,`INST_BEQ,`INST_BLT,`INST_BGE,`INST_BLTU,`INST_BGEU:begin
						rs1_addr_o = rs1;
						rs2_addr_o = rs2;
						op1_o 	   = rs1_data_i;
						op2_o      = rs2_data_i;
						rd_addr_o  = 5'b0;
						reg_wen    = 1'b0;
						base_addr_o		= inst_addr_i;
						addr_offset_o	= {{19{inst_i[31]}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};						
					end	
					default:begin
						rs1_addr_o = 5'b0;
						rs2_addr_o = 5'b0;
						op1_o 	   = 32'b0;
						op2_o      = 32'b0;
						rd_addr_o  = 5'b0;
						reg_wen    = 1'b0;
						base_addr_o		= 32'b0;
						addr_offset_o	= 32'b0;						
					end
				endcase
			end
			`INST_TYPE_L:begin	
				case(func3)
					`INST_LW,`INST_LH,`INST_LB,`INST_LHU,`INST_LBU:begin
						mem_rd_req_o	= 1'b1 ;
						mem_rd_addr_o 	= rs1_data_i + {{20{imm[11]}},imm};
						rs1_addr_o  	= rs1;
						rs2_addr_o  	= 5'b0;
						op1_o 	    	= 32'b0;
						op2_o       	= 32'b0;
						rd_addr_o   	= rd;
						reg_wen     	= 1'b1;	
						base_addr_o   	= rs1_data_i;
						addr_offset_o 	= {{20{imm[11]}},imm};						
					end
					default:begin
						mem_rd_req_o	= 1'b0  ;
						mem_rd_addr_o 	= 32'b0 ;
						rs1_addr_o  	= 5'b0	;
						rs2_addr_o  	= 5'b0	;
						op1_o 	    	= 32'b0	;
						op2_o       	= 32'b0	;
						rd_addr_o   	= 5'b0	;
						reg_wen     	= 1'b0	;					
					end
				endcase
			end
			`INST_TYPE_S:begin
				case(func3)
					`INST_SW,`INST_SH,`INST_SB:begin
						mem_rd_req_o	= 1'b0  		;
						mem_rd_addr_o 	= 32'b0 		;
						rs1_addr_o  	= rs1			;
						rs2_addr_o  	= rs2			;
						op1_o 	    	= 32'b0			;
						op2_o       	= rs2_data_i	;
						rd_addr_o   	= 5'b0			;
						reg_wen     	= 1'b0			;
						base_addr_o     = rs1_data_i	;
						addr_offset_o   = {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};						
					end
					default:begin
						mem_rd_req_o	= 1'b0  ;
						mem_rd_addr_o 	= 32'b0 ;
						rs1_addr_o  	= 5'b0	;
						rs2_addr_o  	= 5'b0	;
						op1_o 	    	= 32'b0	;
						op2_o       	= 32'b0	;
						rd_addr_o   	= 5'b0	;
						reg_wen     	= 1'b0	;
						base_addr_o     = 32'b0;
						addr_offset_o   = 32'b0;						
					end
				endcase
			end
			`INST_JAL:begin
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				rs1_addr_o = 5'b0;
				rs2_addr_o = 5'b0;
				op1_o 	   = inst_addr_i;
				op2_o      = 32'h4;
				rd_addr_o  = rd;
				reg_wen    = 1'b1;
				base_addr_o		= inst_addr_i;
				addr_offset_o	= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};				
			end
			`INST_LUI:begin
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				rs1_addr_o = 5'b0;
				rs2_addr_o = 5'b0;
				op1_o 	   = {inst_i[31:12],12'b0};
				op2_o      = 32'b0;
				rd_addr_o  = rd;
				reg_wen    = 1'b1;
				base_addr_o		= 32'b0;
				addr_offset_o	= 32'b0;				
			end	
			`INST_JALR:begin
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				rs1_addr_o = rs1;
				rs2_addr_o = 5'b0;
				op1_o 	   = inst_addr_i;
				op2_o      = 32'h4;
				rd_addr_o  = rd;
				reg_wen    = 1'b1;	
				base_addr_o		= rs1_data_i;
				addr_offset_o	= {{20{imm[11]}},imm};				
			end
			`INST_AUIPC:begin
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				rs1_addr_o = 5'b0;
				rs2_addr_o = 5'b0;
				op1_o 	   = {inst_i[31:12],12'b0};
				op2_o      = inst_addr_i;
				rd_addr_o  = rd;
				reg_wen    = 1'b1;	
				base_addr_o		= 32'b0;
				addr_offset_o	= 32'b0;				
			end
			default:begin
				mem_rd_addr_o	= 32'b0;
				mem_rd_req_o	= 1'b0;
				rs1_addr_o = 5'b0;
				rs2_addr_o = 5'b0;
				op1_o 	   = 32'b0;
				op2_o      = 32'b0;
				rd_addr_o  = 5'b0;
				reg_wen    = 1'b0;	
				base_addr_o		= 32'b0;
				addr_offset_o	= 32'b0;				
			end
		endcase
	end

	


endmodule