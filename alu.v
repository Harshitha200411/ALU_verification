module alu_design #(parameter b = 8, parameter c = 4)
(
clk,rst,inp_valid,mode,cmd,ce,opa,opb,cin,
err,res,oflow,cout,g,l,e
);

input clk,rst,ce,mode,cin;
input [1:0] inp_valid;
input [c-1:0] cmd;
input [b-1:0] opa,opb;

output reg [2*b-1:0] res;
output reg oflow,cout,g,l,e,err;

reg mul_busy;
reg mul_ready;
reg mul_err;

reg [b-1:0] opa_reg, opb_reg;
reg [c-1:0] cmd_reg;

reg [2*b-1:0] res_next;
reg oflow_next, cout_next, g_next, l_next, e_next, err_next;

wire signed [b-1:0] A = opa;
wire signed [b-1:0] B = opb;
reg signed [b:0] sres;

always @(posedge clk)
begin
//reset logic
 if (rst) begin
  res <= 0; oflow <= 0; cout <= 0; g <= 0; l <= 0; e <= 0; err <= 0;
  res_next <= 0; oflow_next <= 0; cout_next <= 0; g_next <= 0; l_next <= 0; e_next <= 0; err_next <= 0;
  mul_busy <= 0; mul_ready <= 0; mul_err <= 0;
 end

 else if (ce) begin
  // Update outputs with 1-cycle delay
  res <= res_next;
  oflow <= oflow_next;
  cout <= cout_next;
  g <= g_next;
  l <= l_next;
  e <= e_next;
  err <= err_next;

  res_next <= 0;
  oflow_next <= 0;
  cout_next <= 0;
  g_next <= 0;
  l_next <= 0;
  e_next <= 0;
  err_next <= 0;

 //multiplication logic
    //2nd cycle
  if (mul_busy && !mul_ready) begin
    mul_ready <= 1;
    err <= 0;
  end

  //3rd cycle
  else if (mul_busy && mul_ready && cmd == cmd_reg) begin

    if (!mul_err) begin
      case (cmd_reg)
        9:  res <= (opa_reg + 1) * (opb_reg + 1);
        10: res <= (opa_reg << 1) * opb_reg;
        default: res <= 0;
      endcase
      err <= 0;
    end
    else begin
      res <= 0;
      err <= 1;
    end

    //checking if the input changed in the 3rd cycle and taking new input values
    if (mode && (cmd == 9 || cmd == 10)) begin
      opa_reg  <= opa;
      opb_reg  <= opb;
      cmd_reg  <= cmd;
      mul_err  <= (inp_valid != 2'b11);
      mul_busy <= 1;
      mul_ready <= 0;
    end
    else begin
      mul_busy  <= 0;
      mul_ready <= 0;
    end
  end

  //main logic
  else begin
    //arithematic operation
   if (mode) begin
    case (cmd)

     0: begin
          if (inp_valid==2'b11)
            {cout_next, res_next[b-1:0]} <= {1'b0, opa} + {1'b0, opb};
          else
            err_next <= 1;
        end

     1: begin
          if (inp_valid==2'b11) begin
            res_next <= opa - opb;
            oflow_next <= (opa < opb);
          end
          else
            err_next <= 1;
        end

     2: begin
          if (inp_valid==2'b11)
            {cout_next, res_next[b-1:0]} <= {1'b0, opa} + {1'b0, opb} + cin;
          else
            err_next <= 1;
        end

     3: begin
          if (inp_valid==2'b11) begin
            res_next <= opa - opb - cin;
            oflow_next <= (opa < (opb + cin));
          end
          else
            err_next <= 1;
        end

     4: begin
          if (inp_valid==2'b01)
            res_next <= A + 1;
          else
            err_next <= 1;
        end

     5: begin
          if (inp_valid==2'b01)
            res_next <= A - 1;
          else
            err_next <= 1;
        end

     6: begin
          if (inp_valid==2'b10)
            res_next <= B + 1;
          else
            err_next <= 1;
        end

     7: begin
          if (inp_valid==2'b10)
            res_next <= B - 1;
          else
            err_next <= 1;
        end

     8: begin
          if (inp_valid==2'b11) begin
            e_next <= (A == B);
            l_next <= (A < B);
            g_next <= (A > B);
          end
          else
            err_next <= 1;
        end

     9 : begin
        //first cycle
        opa_reg  <= opa;
        opb_reg  <= opb;
        cmd_reg  <= cmd;
        mul_err  <= (inp_valid != 2'b11);
        mul_busy <= 1;
        mul_ready <= 0;
     end

     10: begin
        //first cycle
        opa_reg  <= opa;
        opb_reg  <= opb;
        cmd_reg  <= cmd;
        mul_err  <= (inp_valid != 2'b11);
        mul_busy <= 1;
        mul_ready <= 0;
     end

     11: begin
           if (inp_valid==2'b11) begin
             sres = A + B;
             res_next  <= sres;
             oflow_next <= (A[b-1] == B[b-1]) && (sres[b-1] != A[b-1]);
             e_next <= (A == B);
             l_next <= (A < B);
             g_next <= (A > B);
           end
           else
             err_next <= 1;
         end

     12: begin
           if (inp_valid==2'b11) begin
             sres = A - B;
             res_next  <= sres;
             oflow_next <= (A[b-1] != B[b-1]) && (sres[b-1] != A[b-1]);
             e_next <= (A == B);
             l_next <= (A < B);
             g_next <= (A > B);
           end
           else
             err_next <= 1;
         end

     default: begin
      res_next <= 0; 
      oflow_next <= 0; 
      cout_next <= 0; 
      g_next <= 0; 
      l_next <= 0; 
      e_next <= 0; 
      err_next <= 0;
     end

    endcase
   end

   else begin
    // logical operation
    case (cmd)

     0: begin
          if (inp_valid==2'b11)
            res_next <= opa & opb;
          else
            err_next <= 1;
        end

     1: begin
          if (inp_valid==2'b11)
            res_next <= (~(opa & opb));
          else
            err_next <= 1;
        end

     2: begin
          if (inp_valid==2'b11)
            res_next <= opa | opb;
          else
            err_next <= 1;
        end

     3: begin
          if (inp_valid==2'b11)
            res_next <= (~(opa | opb));
          else
            err_next <= 1;
        end

     4: begin
          if (inp_valid==2'b11)
            res_next <= opa ^ opb;
          else
            err_next <= 1;
        end

     5: begin
          if (inp_valid==2'b11)
            res_next <= (~(opa ^ opb));
          else
            err_next <= 1;
        end

     6: begin
          if (inp_valid==2'b01)
            res_next <= (~opa);
          else
            err_next <= 1;
        end

     7: begin
          if (inp_valid==2'b10)
            res_next <= (~opb);
          else
            err_next <= 1;
        end

     8: begin
          if (inp_valid==2'b01)
            res_next[b-1:0] <= (opa >> 1);
          else
            err_next <= 1;
        end

     9: begin
          if (inp_valid==2'b01)
            res_next[b-1:0] <= (opa << 1);
          else
            err_next <= 1;
        end

     10: begin
           if (inp_valid==2'b10)
             res_next[b-1:0] <= (opb >> 1);
           else
             err_next <= 1;
         end

     11: begin
           if (inp_valid==2'b10)
             res_next[b-1:0] <= (opb << 1);
           else
             err_next <= 1;
         end

     12: begin
           if (inp_valid==2'b11) begin
             res_next[b-1:0] <= (opa << opb[2:0]) | (opa >> (b - opb[2:0]));
             if (|opb[b-1:3]) err_next <= 1;
           end
           else
             err_next <= 1;
         end

     13: begin
           if (inp_valid==2'b11) begin
             res_next[b-1:0] <= (opa >> opb[2:0]) | (opa << (b - opb[2:0]));
             if (|opb[b-1:3]) err_next <= 1;
           end
           else
             err_next <= 1;
         end

     default: begin
      res_next <= 0; 
      oflow_next <= 0; 
      cout_next <= 0; 
      g_next <= 0; 
      l_next <= 0; 
      e_next <= 0; 
      err_next <= 0;
     end

    endcase
   end
  end
 end
end

endmodule
