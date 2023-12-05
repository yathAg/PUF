`timescale 1ns/1ps

module tb_race_arbiter();
  reg en, fin1, fin2, reset; // instantiating inputs to race arbiter
  wire out, done;           // instantiating outputs to race arbiter

  race_arbiter dut(
    .finished1(fin1),
    .finished2(fin2),
    .reset(reset),
    .out(out),
    .done(done)
  ); // instantiating race arbiter DUT

  initial begin
    $display("Start of Race Arbiter Test");
    $monitor("Output of Race Arbiter: %d \t Done: %d \t Time: %d \t fin1 %d \t fin1 %d" , out, done, $time ,fin1, fin2);
    
    // Initialization with ordering
    fin2 = 0;
    fin1 = 0;
    reset = 1;
    #31;
    reset = 0;
    // out should be 0, done should be 0
    fin1 = 0;
    fin2 = 1;
    #20;
    reset = 1;
    #20;
    reset = 0;
    // out should be 1, done should be 1
    fin1 = 1;
    fin2 = 0;
    #20;
    reset = 1;
    #20;
    reset = 0;
    // unknown behavior should be ignored
    fin2 = 1;
    fin1 = 1;
    #20;
    
    $finish;
  end

  always #5 en = !en;

endmodule
