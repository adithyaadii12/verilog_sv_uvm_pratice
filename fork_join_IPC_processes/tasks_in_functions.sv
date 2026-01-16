module top;
  bit b=0;
event e;    
  function void print();
    $display("%0t::inside function",$time);
      fork
        print2("function");
      join_none
// 	  ->e;
    endfunction
    
//   task automatic print2(string name);
      task print2(string name);

//     @e;
//     #0.45;
//       wait(e.triggered);
      #10;
    $display("%0t::inside task  task %s",$time ,name);
    endtask
  initial begin
    fork
      print2("initial");
    join_none
    #0;
//       #11;
    print();
  end
  

  class task_in_post_rand;
    rand bit [7:0] addr;
    rand bit [7:0] data;

    task display_task();
      $display("[TASK] Randomization complete: Addr=0x%h, Data=0x%h", addr, data);
    endtask

    function void post_randomize();
      $display("[FUNC] Inside post_randomize - calling task now...");
      fork
        display_task();  
      join_none
    endfunction
  endclass

  initial begin
    task_in_post_rand tpr;          
    tpr = new();         

    $display("Starting Randomization");
    
    if (!tpr.randomize()) begin
      $error("Randomization failed!");
    end

    $display("task in function");
  end

  
endmodule
