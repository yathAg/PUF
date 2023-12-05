`timescale 1ns/1ps

module testbench_mux_16to1;

  // Parameters
  parameter PERIOD = 10;

  // Inputs
  reg [15:0] in;
  reg [3:0] sel;
  
  // Outputs
  wire out;

  // Instantiate the mux_16to1 module
  mux_16to1 uut (
    .in(in),
    .sel(sel),
    .out(out)
  );

  // Clock generation
  reg clk = 0;
  always #5 clk = ~clk;

  // Initial stimulus
  initial begin
    // Initialize inputs
    in = 16'b0000000000000000;
    sel = 4'b0000;

    // Apply stimulus
    repeat (7) begin
      #PERIOD in = in + 1;
    end

    // Check outputs
    $display("Time\tSel\tInput\t\t\tOutput");
    $monitor("%0t\t%b\t%b\t%b", $time, sel, in, out);

    // Test all possible selections
    repeat (16) begin
      sel = sel + 1;
      #PERIOD;
    end

    // End simulation
    $stop;
  end

endmodule
