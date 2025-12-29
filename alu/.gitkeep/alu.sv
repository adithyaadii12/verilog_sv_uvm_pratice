typedef enum logic [2:0] { add,sub,mul,div,Xor,And} op_code;
module alu(input wire [0:3] a,b,input op_code op,output reg[0:7] y);


  always @(*) begin
    case(op)
      add : y = a+ b;
      sub : y = a-b;
      mul : y = a*b;
      div : y = (b != 0) ? a / b : 0;
      Xor : y = a^b;
      And : y = a & b;
      default : y = 0;

    endcase
  end
endmodule
