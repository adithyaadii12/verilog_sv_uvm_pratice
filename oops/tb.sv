virtual class abstract1;                  //abstract class
  rand logic [3:0] data;         
  rand int value;                     
    
  pure virtual function void display();
endclass
    
    class base extends abstract1;
      local rand int addr;
          // access controller
      protected rand bit [1:0] error;
      // access controller
      const int id = 16; //constmodule tb_alu;

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
ant class property
      constraint c1 { soft data inside {[1:9]};  // before declaring soft it is causing randomization failure when we uncomment rand_mode(0) line
                     value >1 ; value <64;
                     solve addr before error;
                     addr inside {[16:32]};
                     (addr == 32) -> (error == 2'b11);
                      }
      extern function void post_randomize (); // extern
        
        function void display();
             $display("base class level");
        endfunction
      endclass
        
        function void base::post_randomize();
          $display("data = %d, value = %d,addr = %d,error = %d,id = %d ",data,value,addr,error,id);
        endfunction
        
        class child extends base;
          rand int cdata;
          constraint c2 { cdata inside {[33:45]};}
          function void post_randomize();
            super.post_randomize();
            $display("cdata = %d ", cdata);
            //$display ("c_addr  %d ", addr*2);           local variable result in error
            $display("c_error = %d", error+ 1);
          endfunction  // polymorphism and super
          
          function void display1();
            $display("child class level-1");
          endfunction
          
          function void display();
            $display("child class level");
          endfunction
        endclass
        
        
        module tb;
          
          base b;
          child c,c2;
          
          initial begin
          c = new();
          b = c; //upcasting
            b.display();
         
            if ($cast(c2, b)) begin
               c2.display1();   
            end //downcasting
            
          //c.c2.constraint_mode(0);  //disables constraint
          //c.data.rand_mode(0);  //disable randomization  
            c.randomize() with { cdata inside {[35:40]};
                               /*addr == 32;*/
                               }; //inline constraints
          end 
          
        endmodule
          
