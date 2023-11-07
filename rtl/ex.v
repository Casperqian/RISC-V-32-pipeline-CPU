`include "defines.v"

module ex(
	//from id_ex
	input wire[31:0] inst_i,	
	input wire[31:0] inst_addr_i,
	input wire[31:0] op1_i,
	input wire[31:0] op2_i,
	input wire[4:0]  rd_addr_i,
	input wire 		 rd_wen_i,
	input wire[31:0] base_addr_i,
	input wire[31:0] addr_offset_i,	
	
	
	//to regs
	output reg[4:0] rd_addr_o,
	output reg[31:0]rd_data_o,
	output reg 	    rd_wen_o,
	
	//to ctrl
	output reg[31:0]jump_addr_o,
	output reg   	jump_en_o,
	output reg  	hold_flag_o,
	
	//to mem write
	output reg	 	mem_wr_req_o	,
	output reg[3:0] mem_wr_sel_o	,
	output reg[31:0]mem_wr_addr_o	,
	output reg[31:0]mem_wr_data_o	,	
	//from mem read
	input wire[31:0]mem_rd_data_i
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
	
	
	// branch
	//wire[31:0] jump_imm = {{19{inst_i[31]}},inst_i[31],inst_i[7],inst_i[30:25],inst_i[11:8],1'b0}; //改 21+6+4+1
	wire  	   op1_i_equal_op2_i;
	wire       op1_i_less_op2_i_signed;
	wire       op1_i_less_op2_i_unsigned;
	
	assign	   op1_i_less_op2_i_signed = ($signed(op1_i) < $signed(op2_i))?1'b1:1'b0;
	assign	   op1_i_less_op2_i_unsigned = (op1_i < op2_i)?1'b1:1'b0;
	assign	   op1_i_equal_op2_i = (op1_i == op2_i)?1'b1:1'b0;
	

	//ALU
	wire[31:0] op1_i_add_op2_i;										
	wire[31:0] op1_i_and_op2_i;
	wire[31:0] op1_i_xor_op2_i;
	wire[31:0] op1_i_or_op2_i;
	wire[31:0] op1_i_shift_letf_op2_i;
	wire[31:0] op1_i_shift_right_op2_i;
	wire[31:0] base_addr_add_addr_offset;
	
	assign op1_i_add_op2_i           = op1_i + op2_i;				// 加法器
	assign op1_i_and_op2_i           = op1_i & op2_i;			    // 与
	assign op1_i_xor_op2_i           = op1_i ^ op2_i;			    // 异或
	assign op1_i_or_op2_i 			 = op1_i | op2_i;			    // 或
	assign op1_i_shift_letf_op2_i 	 = op1_i << op2_i;			    // 左移
	assign op1_i_shift_right_op2_i 	 = op1_i >> op2_i;			    // 右移
	assign base_addr_add_addr_offset = base_addr_i + addr_offset_i; // 计算地址单元
	
	// tpye I
	wire[31:0] SRA_mask;
	assign 	   SRA_mask = (32'hffff_ffff) >> op2_i[4:0];
	
	wire[1:0]  store_index 	= base_addr_add_addr_offset[1:0];
	wire[1:0]  load_index 	= base_addr_add_addr_offset[1:0];
	
	
	
	always @(*)begin
		
		case(opcode)		
			`INST_TYPE_I:begin
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
				case(func3)				
					`INST_ADDI:begin
						rd_data_o = op1_i_add_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end
					`INST_SLTI:begin
						rd_data_o = {31'b0,op1_i_less_op2_i_signed};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end					
					`INST_SLTIU:begin
						rd_data_o = {31'b0,op1_i_less_op2_i_unsigned};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end					
					`INST_XORI:begin
						rd_data_o = op1_i_xor_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end					
					`INST_ORI:begin
						rd_data_o = op1_i_or_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end					
					`INST_ANDI:begin
						rd_data_o = op1_i_add_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
					end	
					`INST_SLLI:begin
						rd_data_o = op1_i_shift_letf_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;					
					end
					`INST_SRI:begin
						if(func7[5] == 1'b1) begin //SRAI
							rd_data_o = ((op1_i_shift_right_op2_i) & SRA_mask) | ({32{op1_i[31]}} & (~SRA_mask));
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;							
						end
						else begin //SRLI
							rd_data_o = op1_i_shift_right_op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;							
						end
					end					
					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;
					end						
				endcase
			end	
			
			`INST_TYPE_R_M:begin
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
				case(func3)				
					`INST_ADD_SUB:begin
						if(func7[5] == 1'b0)begin//add
							rd_data_o = op1_i_add_op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;
						end
						else begin
							rd_data_o = op1_i - op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1; 								
						end
					end
					`INST_SLL:begin
						rd_data_o = op1_i_shift_letf_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;	
					end
					`INST_SLT:begin
						rd_data_o = {31'b0,op1_i_less_op2_i_signed};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;	
					end
					`INST_SLTU:begin
						rd_data_o = {31'b0,op1_i_less_op2_i_unsigned};
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;	
					end
					`INST_XOR:begin
						rd_data_o = op1_i_xor_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;	
					end	
					`INST_OR:begin
						rd_data_o = op1_i_or_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;	
					end
					`INST_AND:begin
						rd_data_o = op1_i_and_op2_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;	
					end	
					`INST_SR:begin
						if(func7[5] == 1'b1) begin //SRA
							rd_data_o = ((op1_i_shift_right_op2_i) & SRA_mask) | ({32{op1_i[31]}} & (~SRA_mask));
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;							
						end
						else begin //SRL
							rd_data_o = op1_i_shift_right_op2_i;
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;							
						end	
					end						
					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;					
					end
				endcase
			end	
			
			`INST_TYPE_B:begin
				rd_data_o = 32'b0; 
				rd_addr_o = 5'b0;
				rd_wen_o  = 1'b0;			
				case(func3)
					`INST_BEQ:begin
						jump_addr_o = base_addr_add_addr_offset ; 
						jump_en_o	= op1_i_equal_op2_i;
						hold_flag_o = 1'b0;					
					end					
					`INST_BNE:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= ~op1_i_equal_op2_i;
						hold_flag_o = 1'b0;					
					end	
					`INST_BLT:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= op1_i_less_op2_i_signed;
						hold_flag_o = 1'b0;					
					end	
					`INST_BGE:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= ~op1_i_less_op2_i_signed;
						hold_flag_o = 1'b0;					
					end
					`INST_BLTU:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= op1_i_less_op2_i_unsigned;
						hold_flag_o = 1'b0;					
					end
					`INST_BGEU:begin
						jump_addr_o = base_addr_add_addr_offset;
						jump_en_o	= ~op1_i_less_op2_i_unsigned;
						hold_flag_o = 1'b0;					
					end					
					default:begin
						jump_addr_o = 32'b0;
						jump_en_o	= 1'b0;
						hold_flag_o = 1'b0;					
					end
				endcase
			end
			`INST_TYPE_L:begin
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;
				mem_wr_req_o  = 1'b0;
				mem_wr_sel_o  = 4'b0;
				mem_wr_addr_o = 32'b0;
				mem_wr_data_o = 32'b0;				
				case(func3)
					`INST_LW:begin
						rd_data_o = mem_rd_data_i;
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;						
					end
					`INST_LH:begin			
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
						case(load_index[1])
							1'b0:begin
								rd_data_o = {{16{mem_rd_data_i[15]}},mem_rd_data_i[15:0]};	
							end
							1'b1:begin
								rd_data_o = {{16{mem_rd_data_i[31]}},mem_rd_data_i[31:16]};
							end
							default:begin
								rd_data_o = 32'b0;
							end
						endcase
					end						
					`INST_LB:begin			
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
						case(load_index)
							2'b00:begin
								rd_data_o = {{24{mem_rd_data_i[7]}},mem_rd_data_i[7:0]};	
							end
							2'b01:begin
								rd_data_o = {{24{mem_rd_data_i[15]}},mem_rd_data_i[15:8]};
							end
							2'b10:begin
								rd_data_o = {{24{mem_rd_data_i[23]}},mem_rd_data_i[23:16]};
							end
							2'b11:begin
								rd_data_o = {{24{mem_rd_data_i[31]}},mem_rd_data_i[31:24]};
							end
							default:begin
								rd_data_o = 32'b0;
							end
						endcase
					end
					`INST_LHU:begin			
						rd_addr_o = rd_addr_i;
						rd_wen_o  = 1'b1;
						case(load_index[1]) //二字节对齐 所以是第 1 位,第零位默认为0的，其实这里要做处理，
							1'b0:begin		//如果发现最低为不为零要进行硬件报异常(说明你程序员的代码没有二字节对齐，16位对齐)
								rd_data_o = {16'b0,mem_rd_data_i[15:0]};	
							end
							1'b1:begin
								rd_data_o = {16'b0,mem_rd_data_i[31:16]};
							end
							default:begin
								rd_data_o = 32'b0;
							end
						endcase
					end	
					`INST_LBU:begin			
							rd_addr_o = rd_addr_i;
							rd_wen_o  = 1'b1;
							case(load_index)
								2'b00:begin
									rd_data_o = {24'b0,mem_rd_data_i[7:0]};	
								end
								2'b01:begin
									rd_data_o = {24'b0,mem_rd_data_i[15:8]};
								end
								2'b10:begin
									rd_data_o = {24'b0,mem_rd_data_i[23:16]};
								end
								2'b11:begin
									rd_data_o = {24'b0,mem_rd_data_i[31:24]};
								end
								default:begin
									rd_data_o = 32'b0;
								end
							endcase
					end				
					default:begin
						rd_data_o = 32'b0;
						rd_addr_o = 5'b0;
						rd_wen_o  = 1'b0;						
					end
				endcase
			end
			`INST_TYPE_S:begin
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;
				rd_data_o   = 32'b0;
				rd_addr_o   = 5'b0;
				rd_wen_o    = 1'b0;				
				case(func3)
					`INST_SW:begin
						mem_wr_req_o  = 1'b1;
						mem_wr_sel_o  = 4'b1111;
						mem_wr_addr_o = base_addr_add_addr_offset;
						mem_wr_data_o = op2_i;						
					end
					`INST_SH:begin			
						mem_wr_req_o  = 1'b1;
						mem_wr_addr_o = base_addr_add_addr_offset;
						case(store_index)
							1'b0:begin
								mem_wr_data_o = {16'b0,op2_i[15:0]};
								mem_wr_sel_o  = 4'b0011;	
							end
							1'b1:begin
								mem_wr_data_o = {op2_i[15:0],16'b0};
								mem_wr_sel_o  = 4'b1100;	
							end
							default:begin
								mem_wr_data_o = 32'b0;
								mem_wr_sel_o  = 4'b0000;	
							end
						endcase
					end					
					`INST_SB:begin			
						mem_wr_req_o  = 1'b1;
						mem_wr_addr_o = base_addr_add_addr_offset;
						case(store_index)
							2'b00:begin
								mem_wr_data_o = {24'b0,op2_i[7:0]};
								mem_wr_sel_o  = 4'b0001;	
							end
							2'b01:begin
								mem_wr_data_o = {16'b0,op2_i[7:0],8'b0};
								mem_wr_sel_o  = 4'b0010;	
							end
							2'b10:begin
								mem_wr_data_o = {8'b0,op2_i[7:0],16'b0};
								mem_wr_sel_o  = 4'b0100;	
							end
							2'b11:begin
								mem_wr_data_o = {op2_i[7:0],24'b0};
								mem_wr_sel_o  = 4'b1000;	
							end
							default:begin
								mem_wr_data_o = 32'b0;
								mem_wr_sel_o  = 4'b0000;	
							end
						endcase
					end						
					default:begin
						mem_wr_req_o  = 1'b0;
						mem_wr_sel_o  = 4'b0;
						mem_wr_addr_o = 32'b0;
						mem_wr_data_o = 32'b0;						
					end
				endcase
			end			
			`INST_JAL:begin
				rd_data_o = op1_i_add_op2_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = base_addr_add_addr_offset;
				jump_en_o	= 1'b1;
				hold_flag_o = 1'b0;				
			end
			`INST_JALR:begin
				rd_data_o = op1_i_add_op2_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = base_addr_add_addr_offset;
				jump_en_o	= 1'b1;
				hold_flag_o = 1'b0;				
			end				
			`INST_LUI:begin
				rd_data_o = op1_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;			
			end	
			`INST_AUIPC:begin
				rd_data_o = op1_i_add_op2_i;
				rd_addr_o = rd_addr_i;
				rd_wen_o  = 1'b1;
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;				
			end
			default:begin
				rd_data_o = 32'b0;
				rd_addr_o = 5'b0;
				rd_wen_o  = 1'b0;
				jump_addr_o = 32'b0;
				jump_en_o	= 1'b0;
				hold_flag_o = 1'b0;				
			end
		endcase
	end

	
	
	
endmodule