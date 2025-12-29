
module traffic_control_tb;

wire [2:0] n_lights,s_lights,e_lights,w_lights;
reg clk,rst_a;

traffic_control DUT (n_lights,s_lights,e_lights,w_lights,clk,rst_a);

initial
 begin
  clk=1'b1;
  forever #5 clk=~clk;
 end
 
initial
 begin
   #1
  rst_a=1'b1;
  #15;
  rst_a=1'b0;
  #500;
  $stop;
 end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1,traffic_control_tb);
  end
  
  function [7:0] decode_light;
  input [2:0] light;
  begin
    case (light)
      3'b001: decode_light = "G";  // Green
      3'b010: decode_light = "Y";  // Yellow
      3'b100: decode_light = "R";  // Red
      default: decode_light = "?"; // Invalid
    endcase
  end
endfunction
  
  
  always @(posedge clk or posedge rst_a) begin
  $display(
    "TIME=%0t | N=%s S=%s E=%s W=%s | STATE=%0d COUNT=%0d",
    $time,
    decode_light(n_lights),
    decode_light(s_lights),
    decode_light(e_lights),
    decode_light(w_lights),
    DUT.state,
    DUT.count
  );
end
  

  
endmodule
