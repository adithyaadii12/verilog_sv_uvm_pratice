class ipc_fork;
  
  rand int data;
  int value = 10;
  int data1 = 12;
  int data2 = 11;
  event e,e1,e2;
  semaphore s = new(1); // keys = 1
  mailbox mb = new(3); // item can we store : 3  if we leave it blank in new()it unbounded 
  
  constraint dat { data inside {[0:63]} ;}
  
  task a();
    $display("at time %0t starting task a", $time);
    #10
    $display("task a after time %0t", $stime);
    -> e; ->e1; ->e2;
    $display("task a after event triggering event %0t", $time);
    #2
    s.get();
    $display("task a after semaphore %0t", $time);
    #5ns
    $display("task a after semaphore + time %0t",$time);
    s.put();
    
    mb.put(data);
    mb.put(value);
    mb.put(data1);
    mb.put(data2);
    $display(" task a after putting value through MAILBOX %d, data %d,data1 %d,data2%d,time: %0t",value,data,data1,data2,$time);
  endtask
  
  task b();
    #2
    $display("task b starting time %t ",$time );
    @e;
    $display("task b after event e is triggered %t ",$time);
    #11
    @e1;
    $display("task b after event e1 is triggered %t",$time);
    s.get();
    $display("task b after trying to get semaphore %t", $time);
    #2 
    s.put();
    $display("task b after releasing semaphore %t ", $time);
    
    mb.get(data);
    mb.get(value);
    mb.get(data1);
    mb.get(data2);
    $display(" task c after getting through MAILBOX value %d, data %d,data1 %d,data2%d,time: %0t",value,data,data1,data2,$time);
  endtask
  
  task c();
    #0
    $display( " task c starting  time %0t", $stime);
    wait(e2.triggered);
    $display( " task c after wait trigger e2 %0t", $stime);
    s.get();
    $display( " task c after trying to get semaphore time %0t", $stime);
    #4
    s.put();
    $display( " task c after releasing semaphore time %0t", $stime);
    mb.try_get(data);
    mb.try_get(value);
    mb.try_get(data1);
    mb.try_get(data2);
    $display(" task c afterusing non blocking try get getting through MAILBOX value %d, data %d,data1 %d,data2%d,time: %0t",value,data,data1,data2,$time);
  endtask
endclass

module tb;
  ipc_fork ife;
//   ife = new();
  initial begin
      ife = new();
    ife.randomize();

    fork
      begin
        $display("begining of all  types of fork join experiments time %t",$time);
        
        fork
          ife.a();
          ife.b();
          ife.c();
        join
        $display("fork_join_any %t",$time);
        fork
          ife.a();
          ife.b();
          ife.c();
        join_any
        $display("fork_join_none %t",$time);
        fork
          ife.a();
          ife.b();
          ife.c();
        join_none
      end
      #30
      
      begin
        $display("fork disable and wait fork example %0t",$time);
        $display("fork_join_any_wait %t",$time);
        fork
          ife.a();
          ife.b();
          ife.c();
        join_any
        wait fork;
          $display("fork_join_none_disable %t",$time);
        fork
          ife.a();
          ife.b();
          ife.c();
        join_none
        disable fork;
       end
          
       begin
            #1
            $display("fork_join_none_wait %t",$time);
        fork
          ife.a();
          ife.b();
          ife.c();
        join_none
        wait fork;
          $display("fork_any__disable %t",$time);
        fork
          ife.a();
          ife.b();
          ife.c();
        join_any
          disable fork;
            
      end
      join
   end
 endmodule   
        
