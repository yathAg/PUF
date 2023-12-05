`timescale 1s / 1ns

module PUF_tb();

  reg tb_enable;
  reg [7:0] tb_challenge;
  wire [7:0] tb_response;
  reg tb_orred;
  reg tb_reset;
  wire tb_done_sig;

  // Instantiate the PUF module
  PUF uut (
    .enable(tb_enable),
    .challenge(tb_challenge),
    .response(tb_response),
    .orred(tb_orred),
    .reset(tb_reset),
    .done_sig(tb_done_sig)
  );

  initial begin
    // Initialize all inputs
    tb_enable = 0;
    tb_challenge = 0;
    tb_orred = 0;
    tb_reset = 0;

    // Reset the PUF
    tb_reset = 1;
    #10; // Wait for some time
    tb_reset = 0;
    #10;

    // Test different challenges with enable set
    tb_enable = 1;
    tb_challenge = 8'hAA; // Example challenge
    $display("waiting for done");
    wait(tb_done_sig);
    #100;
    $display("im here");
    tb_challenge = 8'h55; // Another challenge
    #200;

    // Test with orred signal
    tb_orred = 1;
    #100;

    // Finish the simulation
    $finish;
  end

  // Optional: Monitor responses and done signal
  always @(posedge tb_done_sig) begin
    $display("Response: %h at time %t", tb_response, $time);
  end

endmodule