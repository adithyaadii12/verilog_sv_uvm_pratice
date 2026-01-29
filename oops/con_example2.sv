localparam int MEM_SIZE = 1024 * 1024; // 1mb 1kb*1kb
localparam int NUM_PARTS = 8;
class mem_partitions;

  rand int unsigned part_size [NUM_PARTS];   
       int unsigned part_start[NUM_PARTS];   
       int unsigned part_end  [NUM_PARTS];   

  
  constraint c_sizes {
    foreach (part_size[i]) {
      part_size[i] > 0;               
      part_size[i] inside {[1:MEM_SIZE]};
    }

    part_size.sum() == MEM_SIZE;
  }

  function void post_randomize();
    part_start[0] = 0;
    part_end[0]   = part_size[0] - 1;

    foreach (part_start[i]) begin
      if (i > 0) begin
        part_start[i] = part_end[i-1] + 1;
        part_end[i]   = part_start[i] + part_size[i] - 1;
      end
    end
  endfunction

endclass

module tb;

  mem_partitions mp;

  initial begin
    mp = new();

    mp.randomize();
    foreach (mp.part_size[i]) begin
      $display("Part %0d : start=%0d end=%0d size=%0d",
               i,
               mp.part_start[i],
               mp.part_end[i],
               mp.part_size[i]);
    end
  end

endmodule


/// finding highest number in a array without using max method.

class max_func;
  rand int a[];
  int temp;
  constraint mf {
    foreach (a[i]) 
      a[i] inside {[1:8]}; }
  
function void post_randomize();
  temp = a[0];  

  foreach (a[i]) begin
    if (a[i] > temp)
      temp = a[i];
  end

  $display("max value : %0d, array %0p", temp, a);
endfunction
endclass

  module tb;
    max_func max;
    initial begin
      max = new();
      max.a = new[4];
      max.randomize();
    end
  endmodule
