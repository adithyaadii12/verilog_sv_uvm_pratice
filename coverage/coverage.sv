class coverage;
  rand bit [7:0] data;
  rand bit [7:0] data2;
  rand logic [3:0] data3;
  rand bit [1:0] data4;
  
  constraint c1 { soft data inside {[127:0]};}
 
  
  covergroup cov with function sample(bit [15:0] d,
                                    bit [7:0]  d2,
                                    logic [3:0] d3,
                                    bit [1:0]  d4);
    option.per_instance = 1;
    option.name = "coverage_example";
    Data: coverpoint d {
      option.comment = "covering data";
      bins low = {[0:3]};
      bins mid = {[4:32]};
      bins high ={[33:$]};
      ignore_bins e14={6};
      illegal_bins e15={7};
    }
    Data2: coverpoint d2 {
      option.comment = "coverage data2";
      bins low_data2 = {[0:3]};
      bins high_data2 = {[4:$]};
    }
    Data3: coverpoint d3;
    Data4: coverpoint d4 {
      option.comment = "transition ex";
      bins trans_bin[] = (2'b00,2'b01 => 2'b10,2'b11);
    }
    data3xdata4: cross data3,data4 {
    ignore_bins illegal = binsof(data4) intersect {2'b11};
    }
  endgroup
  
  function new();
    cov = new();
  endfunction
  
  function string coverage_string();
    string display = {
      $sformatf("\n cover group coverage %03.2f%",cov.get_inst_coverage()),
      $sformatf("\n cover point data %03.2f%",cov.Data.get_inst_coverage()),
      $sformatf("\n cover point data2 %03.2f%",cov.Data2.get_inst_coverage()),
      $sformatf("\n cover point data3 %03.2f%",cov.Data3.get_inst_coverage()),
      $sformatf("\n tran_cov point data4 %03.2f%",cov.Data4.get_inst_coverage()),
      $sformatf("\n cross data3xdata4 %03.2f%",cov.data3xdata4.get_inst_coverage())};
    return display;
  endfunction
endclass

module tb;
  coverage cg;

  initial begin
    cg = new();

    repeat (200) begin
      cg.randomize();
      cg.cov.sample(cg.data, cg.data2, cg.data3, cg.data4);

    end

    $display("%s", cg.coverage_string());
    $finish;
  end
endmodule
