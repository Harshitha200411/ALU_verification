module alu_tb;

  parameter b = 4;
  parameter c = 4;

  reg clk, rst, mode, ce, cin;
  reg [b-1:0]   opa, opb;
  reg [1:0]     inp_valid;
  reg [c-1:0]   cmd;

  wire [2*b-1:0] res_dut;
  wire           oflow_dut, err_dut, l_dut, e_dut, g_dut, cout_dut;

  wire [2*b-1:0] res_ref;
  wire           oflow_ref, err_ref, l_ref, e_ref, g_ref, cout_ref;

  integer pass_count, fail_count;

  alu #(b) a1 (
    .clk(clk), .rst(rst), .ce(ce), .cin(cin), .mode(mode),
    .opa(opa), .opb(opb), .cmd(cmd), .inp_valid(inp_valid),
    .res(res_dut), .oflow(oflow_dut), .err(err_dut),
    .l(l_dut), .e(e_dut), .g(g_dut), .cout(cout_dut)
  );

  reference #(b, c) a2 (
    .clk(clk), .rst(rst), .ce(ce), .cin(cin), .mode(mode),
    .opa(opa), .opb(opb), .cmd(cmd), .inp_valid(inp_valid),
    .res(res_ref), .oflow(oflow_ref), .err(err_ref),
    .l(l_ref), .e(e_ref), .g(g_ref), .cout(cout_ref)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  task apply;
    input [50*8:1] id;
    input          t_rst;
    input          t_mode;
    input          t_ce;
    input          t_cin;
    input [1:0]    t_inp_valid;
    input [c-1:0]  t_cmd;
    input [b-1:0]  t_opa;
    input [b-1:0]  t_opb;
    begin
      @(posedge clk); #1;
      rst       = t_rst;
      mode      = t_mode;
      ce        = t_ce;
      cin       = t_cin;
      inp_valid = t_inp_valid;
      cmd       = t_cmd;
      opa       = t_opa;
      opb       = t_opb;
      @(posedge clk);
      @(posedge clk);
      @(posedge clk); #1;
      if ((res_dut   == res_ref)   &&
          (err_dut   == err_ref)   &&
          (oflow_dut == oflow_ref) &&
          (g_dut     == g_ref)     &&
          (l_dut     == l_ref)     &&
          (e_dut     == e_ref)     &&
          (cout_dut  == cout_ref))
      begin
        $display("PASS [%0s] DUT: res=%b oflow=%b err=%b g=%b l=%b e=%b cout=%b",
                  id, res_dut, oflow_dut, err_dut, g_dut, l_dut, e_dut, cout_dut);
        pass_count = pass_count + 1;
      end
      else begin
        $display("FAIL [%0s]", id);
        $display("  DUT: res=%b oflow=%b err=%b g=%b l=%b e=%b cout=%b",
                  res_dut, oflow_dut, err_dut, g_dut, l_dut, e_dut, cout_dut);
        $display("  REF: res=%b oflow=%b err=%b g=%b l=%b e=%b cout=%b",
                  res_ref, oflow_ref, err_ref, g_ref, l_ref, e_ref, cout_ref);
        fail_count = fail_count + 1;
      end
    end
  endtask

  initial begin
    pass_count = 0;
    fail_count = 0;
    rst       = 1;
    mode      = 0;
    ce        = 0;
    cin       = 0;
    inp_valid = 2'b00;
    cmd       = 4'b0000;
    opa       = 4'b0000;
    opb       = 4'b0000;

    repeat (4) @(posedge clk);
    rst = 0;
    repeat (2) @(posedge clk);

    //ID,RST,MODE,CE,CIN,INP_VALID,CMD,OPA,OPB
    apply("RST",   1, 1, 1, 0, 2'b11, 4'b0000, 4'b0011, 4'b0101);
    apply("CE",   0, 1, 0, 0, 2'b11, 4'b1010, 4'b0001, 4'b0011);
    apply("INV_00",   0, 1, 1, 0, 2'b00, 4'b0000, 4'b0001, 4'b0011);
    apply("INV_01",   0, 1, 1, 0, 2'b01, 4'b0000, 4'b0001, 4'b0011);
    apply("INV_10",   0, 1, 1, 0, 2'b10, 4'b0000, 4'b0001, 4'b0011);
    apply("INV_11",   0, 1, 1, 0, 2'b11, 4'b0000, 4'b0001, 4'b0011);


    //ARITHEMATIC
    apply("ADD",   0, 1, 1, 0, 2'b11, 4'b0000, 4'b0011, 4'b0101);
    apply("SUB",   0, 1, 1, 0, 2'b11, 4'b0001, 4'b0111, 4'b0101);
    apply("SUB(A<B)",   0, 1, 1, 0, 2'b11, 4'b0001, 4'b0011, 4'b0101);
    apply("ADD_CIN",   0, 1, 1, 1, 2'b11, 4'b0010, 4'b0011, 4'b0101);
    apply("SUB_CIN",   0, 1, 1, 1, 2'b11, 4'b0011, 4'b0111, 4'b0101);
    apply("SUB_CIN",   0, 1, 1, 1, 2'b11, 4'b0011, 4'b0001, 4'b0011);
    apply("SUB_CIN(A<B)",   0, 1, 1, 1, 2'b11, 4'b0001, 4'b0011, 4'b1111);
    apply("INC_A",   0, 1, 1, 0, 2'b11, 4'b0100, 4'b0011, 4'b0101);
    apply("INC_A",   0, 1, 1, 0, 2'b01, 4'b0100, 4'b0011, 4'b0101);
    apply("DEC_A",   0, 1, 1, 0, 2'b11, 4'b0101, 4'b0011, 4'b0101);
    apply("DEC_A",   0, 1, 1, 0, 2'b01, 4'b0101, 4'b0011, 4'b0101);
    apply("INC_B",   0, 1, 1, 0, 2'b11, 4'b0110, 4'b0011, 4'b0101);
    apply("INC_B",   0, 1, 1, 0, 2'b10, 4'b0110, 4'b0011, 4'b0101);
    apply("DEC_B",   0, 1, 1, 0, 2'b11, 4'b0111, 4'b0011, 4'b0101);
    apply("DEC_B",   0, 1, 1, 0, 2'b10, 4'b0111, 4'b0011, 4'b0101);
    apply("CMP",   0, 1, 1, 0, 2'b11, 4'b1000, 4'b0011, 4'b0101);
    apply("CMP",   0, 1, 1, 0, 2'b11, 4'b1000, 4'b0011, 4'b0011);
    apply("CMP",   0, 1, 1, 0, 2'b11, 4'b1000, 4'b0111, 4'b0101);
    apply("INC_MUL",   0, 1, 1, 0, 2'b11, 4'b1001, 4'b0011, 4'b0011);
    apply("INC_MUL_1",   0, 1, 1, 0, 2'b11, 4'b1001, 4'b1100, 4'b0001);
    apply("SHI_MUL",   0, 1, 1, 0, 2'b11, 4'b1010, 4'b0001, 4'b1111);
    apply("SHI_MUL_1",   0, 1, 1, 0, 2'b11, 4'b1010, 4'b0001, 4'b0011);
    apply("SIG_ADD_1",   0, 1, 1, 0, 2'b11, 4'b1011, 4'sb1111, 4'sb1111);
    apply("SIG_ADD_2",   0, 1, 1, 0, 2'b11, 4'b1011, 4'sb0001, 4'sb0000);
    apply("SIG_ADD_3",   0, 1, 1, 0, 2'b11, 4'b1011, 4'b0000, 4'b0000);
    apply("SIG_ADD_4",   0, 1, 1, 0, 2'b11, 4'b1011, 4'sb1100, 4'sb1000);
    apply("SIG_SUB",   0, 1, 1, 0, 2'b11, 4'b1100, 4'sb1111, 4'sb0001);
    apply("SIG_SUB_1",   0, 1, 1, 0, 2'b11, 4'b1100, 4'sb0000, 4'sb1111);
    apply("SIG_SUB_2",   0, 1, 1, 0, 2'b11, 4'b1100, 4'sb0111, 4'sb0101);
    apply("SIG_SUB_3",   0, 1, 1, 0, 2'b11, 4'b1100, 4'sb0111, 4'sb0111);
    apply("SIG_SUB_4",   0, 1, 1, 0, 2'b11, 4'b0001, 4'b0000, 4'b000);

    //LOGICAL
    apply("AND",   0, 0, 1, 0, 2'b11, 4'b0000, 4'b0111, 4'b0101);
    apply("NAND",   0, 0, 1, 0, 2'b11, 4'b0001, 4'b0111, 4'b0101);
    apply("OR",   0, 0, 1, 0, 2'b11, 4'b0010, 4'b0111, 4'b0101);
    apply("NOR",   0, 0, 1, 0, 2'b11, 4'b0011, 4'b0111, 4'b0101);
    apply("XOR",   0, 0, 1, 0, 2'b11, 4'b0100, 4'b0111, 4'b0101);
    apply("XNOR",   0, 0, 1, 0, 2'b11, 4'b0101, 4'b0111, 4'b0101);
    apply("NOT_A",   0, 0, 1, 0, 2'b01, 4'b0110, 4'b0111, 4'b0101);
    apply("NOT_A",   0, 0, 1, 0, 2'b11, 4'b0110, 4'b0111, 4'b0101);
    apply("NOT_B",   0, 0, 1, 0, 2'b10, 4'b0111, 4'b0111, 4'b0101);
    apply("NOT_B",   0, 0, 1, 0, 2'b11, 4'b0111, 4'b0111, 4'b0101);
    apply("SHR_1_A",   0, 0, 1, 0, 2'b01, 4'b1000, 4'b0111, 4'b0101);
    apply("SHR_1_A",   0, 0, 1, 0, 2'b11, 4'b1000, 4'b0111, 4'b0101);
    apply("SHL_1_A",   0, 0, 1, 0, 2'b01, 4'b1001, 4'b0111, 4'b0101);
    apply("SHL_1_A",   0, 0, 1, 0, 2'b11, 4'b1001, 4'b0111, 4'b0101);
    apply("SHR_1_B",   0, 0, 1, 0, 2'b10, 4'b1010, 4'b0111, 4'b0101);
    apply("SHR_1_B",   0, 0, 1, 0, 2'b11, 4'b1010, 4'b0111, 4'b0101);
    apply("SHL_1_B",   0, 0, 1, 0, 2'b10, 4'b1011, 4'b0111, 4'b0101);
    apply("SHL_1_B",   0, 0, 1, 0, 2'b11, 4'b1011, 4'b0111, 4'b0101);
    apply("ROL_A",   0, 0, 1, 0, 2'b11, 4'b1100, 4'b0111, 4'b0001);
    apply("ROR_A",   0, 0, 1, 0, 2'b11, 4'b1101, 4'b0111, 4'b0001);

    //INVALID_INPUT_ARITHEMATIC
    apply("ADD_IN",   0, 1, 1, 0, 2'b01, 4'b0000, 4'b0011, 4'b0101);
    apply("SUB_IN",   0, 1, 1, 0, 2'b10, 4'b0001, 4'b0111, 4'b0101);
    apply("SUB(A<B)_IN",   0, 1, 1, 0, 2'b00, 4'b0001, 4'b0011, 4'b0101);
    apply("ADD_CIN_IN",   0, 1, 1, 1, 2'b00, 4'b0010, 4'b0011, 4'b0101);
    apply("SUB_CIN_IN",   0, 1, 1, 1, 2'b00, 4'b0011, 4'b0111, 4'b0101);
    apply("INC_A_IN",   0, 1, 1, 0, 2'b00, 4'b0100, 4'b0011, 4'b0101);
    apply("DEC_A_IN",   0, 1, 1, 0, 2'b00, 4'b0101, 4'b0011, 4'b0101);
    apply("INC_B_IN",   0, 1, 1, 0, 2'b00, 4'b0110, 4'b0011, 4'b0101);
    apply("DEC_B_IN",   0, 1, 1, 0, 2'b01, 4'b0111, 4'b0011, 4'b0101);
    apply("CMP_IN",   0, 1, 1, 0, 2'b01, 4'b1000, 4'b0011, 4'b0101);
    apply("CMP_IN",   0, 1, 1, 0, 2'b01, 4'b1000, 4'b0011, 4'b0011);
    apply("CMP_IN",   0, 1, 1, 0, 2'b10, 4'b1000, 4'b0111, 4'b0101);
    apply("INC_MUL_IN",   0, 1, 1, 0, 2'b10, 4'b1001, 4'b0011, 4'b0011);
    apply("SHI_MUL_IN",   0, 1, 1, 0, 2'b10, 4'b1010, 4'b0001, 4'b0011);
    apply("SIG_ADD_IN",   0, 1, 1, 0, 2'b10, 4'b1011, 4'b0011, 4'b0101);
    apply("SIG_SUB_IN",   0, 1, 1, 0, 2'b10, 4'b1100, 4'b0111, 4'b0101);

    //LOGICAL INVALID_INPUT
    apply("AND_IN",   0, 0, 1, 0, 2'b10, 4'b0000, 4'b0111, 4'b0101);
    apply("NAND_IN",   0, 0, 1, 0, 2'b01, 4'b0001, 4'b0111, 4'b0101);
    apply("OR_IN",   0, 0, 1, 0, 2'b10, 4'b0010, 4'b0111, 4'b0101);
    apply("NOR_IN",   0, 0, 1, 0, 2'b01, 4'b0011, 4'b0111, 4'b0101);
    apply("XOR_IN",   0, 0, 1, 0, 2'b01, 4'b0100, 4'b0111, 4'b0101);
    apply("XNOR_IN",   0, 0, 1, 0, 2'b10, 4'b0101, 4'b0111, 4'b0101);
    apply("NOT_A_IN",   0, 0, 1, 0, 2'b00, 4'b0110, 4'b0111, 4'b0101);
    apply("NOT_B_IN",   0, 0, 1, 0, 2'b00, 4'b0111, 4'b0111, 4'b0101);
    apply("SHR_1_A_IN",   0, 0, 1, 0, 2'b00, 4'b1000, 4'b0111, 4'b0101);
    apply("SHL_1_A_IN",   0, 0, 1, 0, 2'b00, 4'b1001, 4'b0111, 4'b0101);
    apply("SHR_1_B_IN",   0, 0, 1, 0, 2'b00, 4'b1010, 4'b0111, 4'b0101);
    apply("SHL_1_B_IN",   0, 0, 1, 0, 2'b00, 4'b1011, 4'b0111, 4'b0101);
    apply("ROL_A_IN",   0, 0, 1, 0, 2'b10, 4'b1100, 4'b0111, 4'b0101);
    apply("ROR_A_IN",   0, 0, 1, 0, 2'b10, 4'b1101, 4'b0111, 4'b0101);

    //CMD_EXCEEDS
    apply("EX_A_CMD",   0, 1, 1, 0, 2'b01, 4'b1111, 4'b0011, 4'b0101);
    apply("EX_L_CMD",   0, 0, 1, 0, 2'b01, 4'b1111, 4'b0011, 4'b0101);

    //OTHER CASES
    apply("ROL_A_IN_B",   0, 0, 1, 0, 2'b11, 4'b1100, 4'b0111, 4'b0101);
    apply("ROR_A_IN_B",   0, 0, 1, 0, 2'b11, 4'b1101, 4'b0111, 4'b0101);

    apply("ADD_EX",   0, 1, 1, 0, 2'b11, 4'b0000, 4'b1111, 4'b0001);
    apply("ADD_CIN_EX",   0, 1, 1, 1, 2'b11, 4'b0000, 4'b1111, 4'b0000);
    apply("SUB_EX",   0, 1, 1, 1, 2'b11, 4'b0001, 4'b0001, 4'b0000);
    apply("AND_0",   0, 0, 1, 1, 2'b11, 4'b0000, 4'b0000, 4'b0000);

    apply("INC_A_EX",   0, 1, 1, 0, 2'b11, 4'b0100, 4'b1111, 4'b0101);
    apply("DEC_A_EX",   0, 1, 1, 0, 2'b11, 4'b0101, 4'b0000, 4'b0101);
    apply("INC_B_EX",   0, 1, 1, 0, 2'b11, 4'b0110, 4'b1111, 4'b1111);
    apply("DEC_B_EX",   0, 1, 1, 0, 2'b11, 4'b0111, 4'b0011, 4'b0000);
    apply("SIG_ADD_OVF_POS", 0, 1, 1, 0, 2'b11, 4'b1011, 4'b0111, 4'b0111);
    apply("SIG_ADD_OVF_NEG", 0, 1, 1, 0, 2'b11, 4'b1011, 4'b1000, 4'b1000);
    apply("SIG_SUB_OVF", 0, 1, 1, 0, 2'b11, 4'b1100, 4'b1000, 4'b0111);
    apply("ROL_ZERO", 0, 0, 1, 0, 2'b11, 4'b1100, 4'b1010, 4'b0000);
    apply("ROR_ZERO", 0, 0, 1, 0, 2'b11, 4'b1101, 4'b1010, 4'b0000);
    apply("ROL_MAX", 0, 0, 1, 0,  2'b11, 4'b1100, 4'b1011, 4'b0011);
    apply("ROR_MAX", 0, 0, 1, 0, 2'b11, 4'b1101, 4'b1011, 4'b0011);
    apply("INC_MUL_ZERO", 0, 1, 1, 0, 2'b11, 4'b1001, 4'b0000, 4'b0000);


    $display("\n===================================");
    $display("  RESULTS:  PASS=%0d  FAIL=%0d", pass_count, fail_count);
    $display("===================================\n");

    $finish;
  end

  initial begin
    #50000;
    $display("TIMEOUT: simulation exceeded 50000 ns");
    $finish;
  end

endmodule
