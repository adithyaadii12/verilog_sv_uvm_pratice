class assertions;
  rand bit a,b,c;
  
  constraint asser { a dist {0:= 30, 1:=70};
                     b dist {0:= 45, 1:=55};
                     c dist {0:= 70, 1:=30};
                   }
  
endclass

module asser_tb;
  assertions as;

  bit clk = 0;
  always #5 clk = ~clk;   

  bit a, b, c;

  initial begin
    $dumpfile("assert.vcd");
    $dumpvars(0, asser_tb);
  end

  // Drive randomized values
  initial begin
    as = new();
    repeat (50) begin
      @(negedge clk)
      assert(as.randomize()) begin
        a = as.a;
        b = as.b;
        c = as.c;
        $display("asserted randomized value a:%0b b:%0b c:%0b time:%0t",
                  a, b, c, $time);
      end //immediate assertion
      else
        $error("randomization failed");
    end
  end

  initial begin
    #200;
    $display("---- Turning OFF assertions ----");
    $assertoff;   
  end

  initial begin
    #300;
    $display("---- Turning ON assertions ----");
    $asserton;    
  end

  initial begin
    #500;
    $finish;
  end

  // Sequences
  sequence aseq; a; endsequence
  sequence bseq; b; endsequence
  sequence cseq; c; endsequence

  sequence ab; a && b; endsequence
  sequence a_not_b; a && !b; endsequence
  sequence a_and_not_c; a && !c; endsequence

  sequence ab_nc;
    (a && b)[=2:3];
  endsequence

  sequence ab_goto;
    (a && b)[->2:3];
  endsequence

  sequence a_not_b_2;
    (a && !b)[*2];
  endsequence

  // Assertions 
  property overlap_implication;
    @(posedge clk) aseq |-> bseq;
  endproperty
  overlap_implication_a: assert property(overlap_implication)
    $display("b is asserted high right when a is high");
  else
    $error("b is not high when a is high");

  property non_overlap;
    @(posedge clk) aseq |=> bseq;
  endproperty
  non_overlap_a: assert property(non_overlap)
    $display("whether b is high after one clock or not after a is high");
  else
    $error("b is not high after a");

  property stable_p;
    @(posedge clk) ab |-> $stable(c);
  endproperty
  stable_a: assert property(stable_p)
    $display("when both a and b are high checks whether c is stable or not");
  else
    $error("c is not stable when a and b are high");

  property past_p;
    @(posedge clk) a_and_not_c |-> $past(b,2);
  endproperty
  past_a: assert property(past_p)
    $display("checks when a=1 and c=0 whether b was high 2 cycles before");
  else
    $error("b was not high 2 cycles before");

  property rose_p;
    @(posedge clk) ab |-> $rose(c);
  endproperty
  rose_a: assert property(rose_p)
    $display("checks whether c rose when a and b are high");
  else
    $error("c did not rise when a and b were high");

  property through_p;
    @(posedge clk)
      a_not_b_2 |-> (c throughout a_not_b[*2]);
  endproperty
  through_a: assert property(through_p)
    $display("c should be high throughout two cycles of a=1 and b=0");
  else
    $error("throughout check failed");

  property within_p;
    @(posedge clk)
      ab_nc |-> c;
  endproperty
  within_a: assert property(within_p)
    $display("c is high within 2 or 3 occurrences of a and b high");
  else
    $error("within check failed");

  property within_goto;
    @(posedge clk)
      ab_goto |-> c;
  endproperty
  within_goto_a: assert property(within_goto)
    $display("c is high within 2 or 3 consecutive a and b highs");
  else
    $error("within goto check failed");

endmodule
