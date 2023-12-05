`timescale 1ns/1ps

module tb_post_mux_counter();
  reg enable, clk, reset; // Instantiating inputs to post mux counter
  wire finished;          // Instantiating outputs to post mux counter
  wire [21:0] out;

  post_mux_counter dut(
    .out(out),
    .finished(finished),
    .enable(enable),
    .clk(clk),
    .reset(reset)
  ); // Instantiating Post-mux Counter dut
  
  initial begin
    $display("Start of Post-mux Counter");
    $monitor("Output of counter: %d \t Finished Val: %d \t Time: %d", out, finished, $time);

    // Initialization
    clk = 0;
    enable = 0;
    reset = 1;
    #6;

    reset = 0;
    enable = 1;
    #8000;
    
    $finish;
  end

  always #5 clk = ~clk;
endmodule
