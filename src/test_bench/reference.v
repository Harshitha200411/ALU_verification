module reference #(parameter b = 4, c = 4)(clk,cin,rst,ce,inp_valid,cmd,mode,opa,opb,err,e,l,g,res,cout,oflow);
input cin,clk,rst,ce,mode;
input [1:0]inp_valid;
input [c-1:0]cmd;
input [b-1:0]opa,opb;
output reg [2*b-1:0]res;
output reg err,l,e,g,cout,oflow;

reg signed [2*b-1:0] sres;
reg signed [b-1:0] a;
reg signed [b-1:0] d;

always @ (*)
begin
 a = opa;
 d = opb;
 if (rst)
  begin
   res = 0; err = 0; l = 0; e = 0; g = 0; cout = 0; oflow = 0;
  end
 else
  begin
   if (ce)
    begin
     if (mode)
      begin
       res = 0; err = 0; l = 0; e = 0; g = 0; cout = 0; oflow = 0;
       case (cmd)
        0 : begin
         if (inp_valid == 2'b11) begin
          {cout,res[b-1:0]} = opa + opb;
         end
         else begin
          res = 0; err = 1;
         end
        end
        1 : begin
         if (inp_valid == 2'b11) begin
          res[b-1:0] = opa - opb;
          oflow = opa < opb;
         end
         else begin
          res = 0; err = 1;
         end
        end
        2 : begin
         if (inp_valid == 2'b11) begin
          res[b-1:0] = opa + opb + cin;
          cout  = res[b];
         end
         else begin
          res = 0; err = 1;
         end
        end
        3 : begin
         if (inp_valid == 2'b11) begin
          res[b-1:0] = opa - opb - cin;
          oflow = opa < (opb + cin);
         end
         else begin
          res = 0; err = 1;
         end
        end
        4 : begin
         if (inp_valid == 2'b01 || inp_valid == 2'b11)
          res[b-1:0] = opa + 1;
         else begin
          res = 0; err = 1;
         end
        end
        5 : begin
         if (inp_valid == 2'b01 || inp_valid == 2'b11)
          res[b-1:0] = opa - 1;
         else begin
          res = 0; err = 1;
         end
        end
        6 : begin
         if (inp_valid == 2'b10 || inp_valid == 2'b11)
          res[b-1:0] = opb + 1;
         else begin
          res = 0; err = 1;
         end
        end
        7 : begin
         if (inp_valid == 2'b10 || inp_valid == 2'b11)
          res[b-1:0] = opb - 1;
         else begin
          res = 0; err = 1;
         end
        end
        8 : begin
         if (inp_valid == 2'b11)
          begin
           g = (opa > opb);
           l = (opa < opb);
           e = (opa == opb);
          end
         else begin
          res = 0; err = 1;
         end
        end
        9 : begin
         if (inp_valid == 2'b11)
          res = (opa + 1) * (opb + 1);
         else begin
          res = 0; err = 1;
         end
        end
        10 : begin
         if (inp_valid == 2'b11)
          res = (opa << 1) * opb;
         else begin
          res = 0; err = 1;
         end
        end
        11 : begin
         if (inp_valid == 2'b11)
          begin
           sres = a + d;
           res[b-1:0] = sres;
           oflow = (a[b-1] == d[b-1]) && (a[b-1] != sres[b-1]);
           e = (a == d);
           l = (a < d);
           g = (a > d);
          end
         else begin
          res = 0; err = 1;
         end
        end
        12 : begin
         if (inp_valid == 2'b11)
          begin
           sres = a - d;
           res[b-1:0] = sres;
           oflow = (a[b-1] != d[b-1]) && (a[b-1] != sres[b-1]);
           e = (a == d);
           l = (a < d);
           g = (a > d);
          end
         else begin
          res = 0; err = 1;
         end
        end
        default : begin
         res = 0; l = 0; e = 0; g = 0; oflow = 0; cout = 0; err = 1;
        end
       endcase
      end
     else
      begin
         res = 0; err = 0; l = 0; e = 0; g = 0; cout = 0; oflow = 0;
       case (cmd)
        0 : begin
         if (inp_valid == 2'b11)
          res[b-1:0] = opa & opb;
         else begin
          res = 0; err = 1;
         end
        end
        1 : begin
         if (inp_valid == 2'b11)
          res[b-1:0] = ~(opa & opb);
         else begin
          res = 0; err = 1;
         end
        end
        2 : begin
         if (inp_valid == 2'b11)
          res[b-1:0] = opa | opb;
         else begin
          res = 0; err = 1;
         end
        end
        3 : begin
         if (inp_valid == 2'b11)
          res[b-1:0] = ~(opa | opb);
         else begin
          res = 0; err = 1;
         end
        end
        4 : begin
         if (inp_valid == 2'b11)
          res[b-1:0] = opa ^ opb;
         else begin
          res = 0; err = 1;
         end
        end
        5 : begin
         if (inp_valid == 2'b11)
          res[b-1:0] = ~(opa ^ opb);
         else begin
          res = 0; err = 1;
         end
        end
        6 : begin
         if (inp_valid == 2'b01 || inp_valid == 2'b11)
          res[b-1:0] = ~opa;
         else begin
          res = 0; err = 1;
         end
        end
        7 : begin
         if (inp_valid == 2'b10 || inp_valid == 2'b11)
          res[b-1:0] = ~opb;
         else begin
          res = 0; err = 1;
         end
        end
        8 : begin
         if (inp_valid == 2'b01 || inp_valid == 2'b11)
          res[b-1:0] = opa >> 1;
         else begin
          res = 0; err = 1;
         end
        end
        9 : begin
         if (inp_valid == 2'b01 || inp_valid == 2'b11)
          res[b-1:0] = opa << 1;
         else begin
          res = 0; err = 1;
         end
        end
        10 : begin
         if (inp_valid == 2'b10 || inp_valid == 2'b11)
          res[b-1:0] = opb >> 1;
         else begin
          res = 0; err = 1;
         end
        end
        11 : begin
         if (inp_valid == 2'b10 || inp_valid == 2'b11)
          res[b-1:0] = opb << 1;
         else begin
          res = 0; err = 1;
         end
        end
        12 : begin
         if (inp_valid == 2'b11) begin
          res[b-1:0] = opa << opb[$clog2(b)-1:0] | opa >> (b - opb[($clog2(b)-1):0]);
          err = |opb[b-1:$clog2(b)];
         end
         else begin
          res = 0; err = 1;
         end
        end
        13 : begin
         if (inp_valid == 2'b11) begin
          res[b-1:0] = opa >> opb[$clog2(b)-1:0] | opa << (b - opb[($clog2(b)-1):0]);
          err = |opb[b-1:$clog2(b)];
         end
         else begin
          res = 0; err = 1;
         end
        end
        default : begin
         res = 0; err = 1; l = 0; e = 0; g = 0; cout = 0; oflow = 0;
        end
       endcase
      end
    end
  end
end

endmodule
