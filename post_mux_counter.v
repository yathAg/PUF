module post_mux_counter (
  output reg [21:0] out,    // Output of the counter
  output reg finished,      // Output finished signal
  input enable,             // enable for counter
  input clk,                // clock Input
  input reset               // reset Input
  );

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      out <= 28'd0;
      finished <= 1'b0;
    end
    else if (out[21] == 1) begin
      finished <= 1'b1;
    end
    else if (enable) begin
      out <= out + 1;
    end
  end
endmodule