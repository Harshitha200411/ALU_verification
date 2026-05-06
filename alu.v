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

reg [b-1:0] opa_reg, opb_reg;
reg [c-1:0] cmd_reg;

wire signed [b-1:0] A = opa;
wire signed [b-1:0] B = opb;
reg signed [b:0] sres;


always @(posedge clk)
begin
 if (rst) begin
  res <= 0; oflow <= 0; cout <= 0; g <= 0; l <= 0; e <= 0; err <= 0;
  mul_busy <= 0; mul_ready <= 0;
 end
 else if (ce) begin
  if (mul_busy && !mul_ready) begin
   mul_ready <= 1;
  end
  else if (mul_busy && mul_ready) begin
   case (cmd_reg)
    9:  res <= (opa_reg + 1) * (opb_reg + 1);
    10: res <= (opa_reg << 1) * opb_reg;
   endcase
   mul_busy  <= 0;
   mul_ready <= 0;
  end
  else begin

   res <= 0; oflow <= 0; cout <= 0; g <= 0; l <= 0; e <= 0; err <= 0;

   if (mode) begin
    case (cmd)

     0: if (inp_valid==2'b11) begin
          res <= 0;
          {cout, res[b-1:0]} <= {1'b0, opa} + {1'b0, opb};
         end

     1: if (inp_valid==2'b11) begin
          res <= opa - opb;
          oflow <= (opa < opb);
         end

     2: if (inp_valid==2'b11) begin
          res <= 0;
          {cout, res[b-1:0]} <= {1'b0, opa} + {1'b0, opb} + cin;
         end

     3: if (inp_valid==2'b11) begin
          res <= opa - opb - cin;
          oflow <= (opa < (opb + cin));
         end

     4: if (inp_valid==2'b01) res <= A + 1;
     5: if (inp_valid==2'b01) res <= A - 1;
     6: if (inp_valid==2'b10) res <= B + 1;
     7: if (inp_valid==2'b10) res <= B - 1;

     8: if (inp_valid==2'b11) begin
          e <= (A == B);
          l <= (A < B);
          g <= (A > B);
         end

     9, 10: if (inp_valid == 2'b11) begin
              opa_reg  <= opa;
              opb_reg  <= opb;
              cmd_reg  <= cmd;
              mul_busy <= 1;
              mul_ready <= 0;
             end

     11: if (inp_valid==2'b11) begin
           sres = A + B;
           res  <= sres;
           oflow <= (A[b-1] == B[b-1]) && (sres[b-1] != A[b-1]);
           e <= (A == B);
           l <= (A < B);
           g <= (A > B);
          end

     12: if (inp_valid==2'b11) begin
           sres = A - B;
           res  <= sres;
           oflow <= (A[b-1] != B[b-1]) && (sres[b-1] != A[b-1]);
           e <= (A == B);
           l <= (A < B);
           g <= (A > B);
          end

     default: begin
      res <= 0; oflow <= 0; cout <= 0; g <= 0; l <= 0; e <= 0; err <= 0;
     end

    endcase
   end
   else begin
    res <= 0; oflow <= 0; cout <= 0; g <= 0; l <= 0; e <= 0; err <= 0;
    case (cmd)
     0: if (inp_valid==2'b11) res[b-1:0] <= opa & opb;
     1: if (inp_valid==2'b11) res[b-1:0] <= (~(opa & opb));
     2: if (inp_valid==2'b11) res[b-1:0] <= opa | opb;
     3: if (inp_valid==2'b11) res[b-1:0] <= (~(opa | opb));
     4: if (inp_valid==2'b11) res[b-1:0] <= opa ^ opb;
     5: if (inp_valid==2'b11) res[b-1:0] <= (~(opa ^ opb));

     6: if (inp_valid==2'b01) res[b-1:0] <= (~opa);
     7: if (inp_valid==2'b10) res[b-1:0] <= (~opb);

     8: if (inp_valid==2'b01) res[b-1:0] <= opa >> 1;
     9: if (inp_valid==2'b01) res[b-1:0] <= opa << 1;

     10: if (inp_valid==2'b10) res[b-1:0] <= opb >> 1;
     11: if (inp_valid==2'b10) res[b-1:0] <= opb << 1;

     12: if (inp_valid==2'b11) begin
           res[b-1:0] <= (opa << opb[2:0]) | (opa >> (b - opb[2:0]));
           if (|opb[b-1:3]) err <= 1;
          end

     13: if (inp_valid==2'b11) begin
           res[b-1:0] <= (opa >> opb[2:0]) | (opa << (b - opb[2:0]));
           if (|opb[b-1:3]) err <= 1;
          end

     default: begin
      res <= 0; oflow <= 0; cout <= 0; g <= 0; l <= 0; e <= 0; err <= 0;
     end

    endcase
   end
  end
 end
end

endmodule
