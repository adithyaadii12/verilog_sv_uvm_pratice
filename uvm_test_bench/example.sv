import uvm_pkg::*;
`include "uvm_macros.svh"

interface example_if(input clk);
  logic [15:0] data;
  logic [11:0] value;
  logic enable;
  logic [3:0] addr;
endinterface


class my_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(my_sequence_item)

  function new(string name = "");
    super.new(name);
  endfunction

  rand logic [15:0] data;
  rand logic [11:0] value;
  logic enable;
  rand logic [3:0] addr;

  constraint dc {
    data inside {[256:1024]};
    value inside {[32:255]};
    if (data < 513)
      addr inside {[0:7]};
    else
      addr inside {[8:15]};
  }
endclass


class my_sequencer #(type ITEM_DRV = my_sequence_item)
  extends uvm_sequencer #(ITEM_DRV);
  `uvm_component_param_utils(my_sequencer#(ITEM_DRV))

  function new(string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction
endclass


class my_sequence #(type ITEM_DRV = my_sequence_item)
  extends uvm_sequence #(ITEM_DRV);
  `uvm_object_param_utils(my_sequence#(ITEM_DRV))
  `uvm_declare_p_sequencer(my_sequencer#(ITEM_DRV))

  function new(string name = "");
    super.new(name);
  endfunction

  virtual task body();
    ITEM_DRV req;
    req = ITEM_DRV::type_id::create("req");
    start_item(req);
    void'(req.randomize());
    finish_item(req);
  endtask
endclass


class my_driver extends uvm_driver #(my_sequence_item);
  `uvm_component_utils(my_driver)

  virtual example_if vif;
  event drv_done;

  function new(string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    my_sequence_item item;
    forever begin
      seq_item_port.get_next_item(item);
      @(posedge vif.clk);
      if (vif.enable) begin
        vif.addr  <= item.addr;
        vif.data  <= item.data;
        vif.value <= item.value;
        $display("DRIVER:        addr:%d,data:%d,value:%d,time:%0t",item.addr,item.data,item.value,$time);
      end
      seq_item_port.item_done();
      ->drv_done;
    end
  endtask
endclass


class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)

  virtual example_if vif;
  uvm_analysis_port #(my_sequence_item) out_port;
  event drv_done;


  function new(string name = "", uvm_component parent);
    super.new(name,parent);
    out_port = new("out_port", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    my_sequence_item item;
    forever begin
      @drv_done;
      #1ns;
      item = my_sequence_item::type_id::create("item");
      item.enable = vif.enable;
      item.addr   = vif.addr;
      item.data   = vif.data;
      item.value  = vif.value;
      $display("monitor : enable = %d, addr : %d,data = %d,value : %d,time :%0t", item.enable,item.addr,item.data,item.value,$time);
      out_port.write(item);
    end
  endtask
endclass


class my_agent extends uvm_agent;
  `uvm_component_utils(my_agent)

  uvm_active_passive_enum active_passive = UVM_ACTIVE;
  virtual example_if vif;

  my_driver    driver;
  my_monitor   monitor;
  my_sequencer #(my_sequence_item) sequencer;
  event drv_done;

  function new(string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
//     drv_done = new;
    if (!uvm_config_db#(virtual example_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Virtual interface not set")
      

    monitor = my_monitor::type_id::create("monitor",this);
    monitor.vif = vif;
    
    if (active_passive == UVM_ACTIVE) begin
      driver    = my_driver::type_id::create("driver",this);
      sequencer = my_sequencer#(my_sequence_item)::type_id::create("sequencer",this);
      driver.vif = vif;
      driver.drv_done  = drv_done;
      monitor.drv_done = drv_done;
      
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (active_passive == UVM_ACTIVE)
      driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass


class my_env extends uvm_env;
  `uvm_component_utils(my_env)

  my_agent agent;

  function new(string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent",this);
  endfunction
endclass


class my_test extends uvm_test;
  `uvm_component_utils(my_test)

  my_env env;

  function new(string name = "", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = my_env::type_id::create("env",this);
  endfunction

  task run_phase(uvm_phase phase);
    my_sequence#(my_sequence_item) seq;
    phase.raise_objection(this);
    seq = my_sequence#(my_sequence_item)::type_id::create("seq");
    seq.start(env.agent.sequencer);
    #20;
    phase.drop_objection(this);
  endtask
endclass


module tb;
  bit clk = 0;
  always #5 clk = ~clk;

  example_if vif(clk);

  initial begin
    vif.enable = 1'b1;
    uvm_config_db#(virtual example_if)::set(null,"uvm_test_top.env.agent","vif",vif);
    run_test("my_test");
  end
endmodule

  
