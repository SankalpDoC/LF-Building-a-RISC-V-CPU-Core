\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/main/lib/risc-v_shell_lib.tlv'])



   //---------------------------------------------------------------------------------
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  x12 (a2): 10
   //  x13 (a3): 1..10
   //  x14 (a4): Sum
   // 
   m4_asm(ADDI, x14, x0, 0)             // Initialize sum register a4 with 0
   m4_asm(ADDI, x12, x0, 1010)          // Store count of 10 in register a2.
   m4_asm(ADDI, x13, x0, 1)             // Initialize loop count register a3 with 0
   // Loop:
   m4_asm(ADD, x14, x13, x14)           // Incremental summation
   m4_asm(ADDI, x13, x13, 1)            // Increment loop count by 1
   m4_asm(BLT, x13, x12, 1111111111000) // If a3 is less than a2, branch to label named <loop>
   // Test result value in x14, and set x31 to reflect pass/fail.
   m4_asm(ADDI, x30, x14, 111111010100) // Subtract expected value of 44 to set x30 to 1 if and only iff the result is 45 (1 + 2 + ... + 9).
   m4_asm(BGE, x0, x0, 0) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   m4_asm_end()
   m4_define(['M4_MAX_CYC'], 50)
   //---------------------------------------------------------------------------------



\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   
   $reset = *reset;
   
   $pc[31:0] = >>1$next_pc;
   
   //implemented pc lab 1
   `READONLY_MEM($pc , $$instr[31:0])
   //implemented IMem lab 2
   
   $is_i_instr = $instr[6:2] ==? 5'b0000x || 
                 $instr[6:2] ==? 5'b001x0 || 
                 $instr[6:2] ==? 5'b11001;
   
   $is_r_instr = $instr[6:2] ==? 5'b10100 ||
                 $instr[6:2] ==? 5'b011x0 ||
                 $instr[6:2] ==? 5'b01011;
   
   $is_s_instr = $instr[6:2] ==? 5'b0100x;
   
   $is_b_instr = $instr[6:2] ==? 5'b11000;
   
   $is_j_instr = $instr[6:2] ==? 5'b11011;
   
   $is_u_instr = $instr[6:2] ==? 5'b0x101;
   //Implemented 
   
   $funct7[6:0] = $instr[31:25];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0] = $instr[19:15];
   $rs2[4:0] = $instr[24:20];
   $rd[4:0] = $instr[11:7];
   $opcode[6:0] = $instr[6:0];
   
   $funct7_valid = $is_r_instr;
   $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rs1_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
   $rs2_valid = $is_r_instr || $is_s_instr || $is_b_instr;
   $rd_valid = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
   $imm_valid = $is_u_instr || $is_i_instr || $is_s_instr || $is_b_instr || $is_j_instr;
   
   //`BOGUS_USE($funct3 $funct3_valid $funct7 $funct7_valid $imm_valid $opcode $rd $rd_valid $rs1 $rs1_valid $rs2 $rs2_valid)
   
   $imm[31:0] = $is_i_instr ? {  {21{$instr[31]}},  $instr[30:20]  } :
                $is_s_instr ? {  {21{$instr[31]}},  $instr[30:25],  $instr[11:7] } :
                $is_b_instr ? {  {20{$instr[31]}},  $instr[7],  $instr[30:25],  $instr[11:8], 1'b0} :
                $is_u_instr ? {  $instr[31],  $instr[30:12],  12'b0 } :
                $is_j_instr ? {  {12{$instr[31]}},  $instr[19:12],  $instr[20],  $instr[30:21],  1'b0  } :
                              32'b0;  // Default
   //Implemented 
   
   $dec_bits[10:0] = {$funct7[5],$funct3,$opcode};
   $is_beq = $dec_bits ==? 11'bx_000_1100011;
   $is_bne = $dec_bits ==? 11'bx_001_1100011;
   $is_blt = $dec_bits ==? 11'bx_100_1100011;
   $is_bge = $dec_bits ==? 11'bx_101_1100011;
   $is_bltu = $dec_bits ==? 11'bx_110_1100011;
   $is_bgeu = $dec_bits ==? 11'bx_111_1100011;
   $is_addi = $dec_bits ==? 11'bx_000_0010011;
   $is_add = $dec_bits ==? 11'b0_000_0110011;
   
   //`BOGUS_USE($imm $is_add $is_addi $is_beq $is_bge $is_bgeu $is_blt $is_bltu $is_bne)
   // Lab 3 DECoder Implemented
   
   
   
   $rd_en1 = $rs1_valid;
   $rd_en2 = $rs2_valid;
   
   $rd_index1[4:0] = $rd_en1 ? $rs1 : 5'b0;
   $rd_index2[4:0] = $rd_en2 ? $rs2 : 5'b0;
   
   $src1_value[31:0] = $rd_en1 ? $rd_data1 : 'X;
   $src2_value[31:0] = $rd_en2 ? $rd_data2 : 'X;
   // Lab 4 Register File Read Implemented
   
   $result[31:0] = $is_addi ? $src1_value + $imm :
                   $is_add ? $src1_value + $src2_value :
                             32'b0;
   // Lab 5 ALU Implemented
   
   // $wr_en = $rd_valid;
   $wr_en = {$rd == 5'd0} ? 1'b0 : $rd_valid;
   $wr_index[4:0] = $wr_en ? $rd : 'X;
   $wr_data[31:0] = $wr_en ? $result : 'X;
   
   // Lab 6 Register File Write Implemented
   
   $taken_br = $is_beq ? ($src1_value == $src2_value) :
               $is_bne ? ($src1_value != $src2_value) :
               $is_blt ? (($src1_value < $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
               $is_bge ? (($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31])) :
               $is_bltu ? ($src1_value < $src2_value) :
               $is_bgeu ? ($src1_value >= $src2_value) :
                                           1'b0;
   
   $br_tgt_pc[31:0] = $taken_br ? $pc + $imm : $pc;
   $next_pc[31:0] = $reset ? '0 :
                    $taken_br ? $br_tgt_pc :
                    $pc + 32'd4;
   // Lab 7 Branch Logic Implemented
   
   // Assert these to end simulation (before Makerchip cycle limit).
   m4+tb()
   *failed = *cyc_cnt > M4_MAX_CYC;
   
   m4+rf(32, 32, $reset, $wr_en, $wr_index[4:0], $wr_data[31:0], $rd_en1, $rd_index1[4:0], $rd_data1, $rd_en2, $rd_index2[4:0], $rd_data2)
   //m4+dmem(32, 32, $reset, $addr[4:0], $wr_en, $wr_data[31:0], $rd_en, $rd_data)
   m4+cpu_viz()

\SV
   endmodule
