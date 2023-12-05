`timescale 1ns/1ps

module tb_ring_osc();

  wire w14;

  reg en;
  
  ring_osc ro0(.enable(en), .out(w14));

  initial begin
    $display("Starting Ring Oscillator Test");
    $monitor("Output of ro0: %b\t Time: %0t", w14, $time);
    
    // Enable the ring oscillator
    en = 1;
    #10;

    // Disable the ring oscillator
    en = 0;
    #20;

    // Enable the ring oscillator again
    en = 1;
    #200;

    // Finish the simulation
    $finish;
  end

endmodule
