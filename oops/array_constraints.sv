typedef enum { READ, WRITE, FLUSH } op_t;

class packet;

  // Random fields
  rand int   data[];     // dynamic array
  rand int   size;
  rand op_t  op;

  constraint c_size {
    size inside {[4:8]};
    data.size() == size;
  }

  constraint c_data_range {
    foreach (data[i])
      data[i] inside {[0:255]};
  }

  constraint c_monotonic {
    foreach (data[i])
      if (i > 0)
        data[i] >= data[i-1];
  } //foreach + conditional

  constraint c_op_weighted {
    op dist {
      READ  := 60,
      WRITE := 30,
      FLUSH := 10
    };
  } // ranodm weight case

  // Conditional + weighted array 
  constraint c_data_weighted {
    foreach (data[i]) {
      if (op == READ)
        data[i] dist { [0:63] := 70, [64:255] := 30 };
      else if (op == WRITE)
        data[i] dist { [64:255] := 80, [0:63] := 20 };
      else
        data[i] == 0; 
    }
  }

endclass
      
 module tb;
  initial begin
    packet p = new();

    assert(p.randomize())
    $display("op=%0s size=%0d data=%p", p.op.name(), p.size, p.data);
    else $error("randomization failed");

    // Inline constraint 
    assert(p.randomize() with {
      size == 6;
      op == WRITE;
    });
    $display("INLINE -> op=%0s size=%0d data=%p",
              p.op.name(), p.size, p.data);
  end
endmodule
