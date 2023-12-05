module puf_parallel_subblock(
    input [7:0] challenge,
    input enable,
    output reg out,
    output reg done,
    input reset
);

    wire [31:0] ro_out;                   // a 32-bit bus: each stems from the output of each ro
    wire first_mux_out, second_mux_out;   // output of muxes that go into the counters
    wire fin1, fin2;                      // outputs of the counters that go into the race arbiter
    wire [21:0] pmc1_out, pmc2_out;       // for debug, output of the counters

    // Instantiate 16 ring oscillators for the first array
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : first_ro_inst
        ring_osc first_ro_inst (
            .out(ro_out[i]),
            .enable(enable)
        );
        end
    endgenerate

    // Instantiate 16 ring oscillators for the second array
    generate
        for (i = 0; i < 16; i = i + 1) begin : second_ro_inst
        ring_osc second_ro_inst (
            .out(ro_out[i + 16]),
            .enable(enable)
        );
        end
    endgenerate

    mux_16to1 first_mux (
    .in(ro_out[0:15]),
    .sel(challenge[3:0]),
    .out(first_mux_out)
    );

    mux_16to1 second_mux (
    .in(ro_out[16:31]),
    .sel(challenge[7:4]),
    .out(second_mux_out)
    );

    post_mux_counter pmc1 (
    .out(pmc1_out),
    .finished(fin1),
    .enable(enable[0]),
    .clk(first_mux_out),
    .reset(reset)
    );
  
    post_mux_counter pmc2 (
    .out(pmc2_out),
    .finished(fin2),
    .enable(enable[0]),
    .clk(second_mux_out),
    .reset(reset)
    );

    race_arbiter arb (
    .finished1(fin1),
    .finished2(fin2),
    .reset(reset),
    .out(out),
    .done(done)
    );
endmodule