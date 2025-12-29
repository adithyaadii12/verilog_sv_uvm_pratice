module tb_alu;

  // DUT signals
  logic [0:3] a, b;
  op_code     op;
  logic [0:7] y;

  alu dut (
    .a(a),
    .b(b),
    .op(op),
    .y(y)
  );

  // Task to apply stimulus
  task apply(input [0:3] ta, tb, input op_code top);
    begin
      a  = ta;
      b  = tb;
      op = top;
      #1;
      $display("a=%0d b=%0d op=%0s -> y=%0d", a, b, op.name(), y);
    end
  endtask

  initial begin
    $display("---- ALU TEST START ----");

    apply(4'd5, 4'd3, add);
    apply(4'd5, 4'd3, sub);
    apply(4'd5, 4'd3, mul);
    apply(4'd6, 4'd2, div);
    apply(4'd6, 4'd0, div); // divide by zero
    apply(4'd5, 4'd3, Xor);
    apply(4'd5, 4'd3, And);

    $display("---- ALU TEST END ----");
    $finish;
  end
