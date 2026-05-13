/*
 * tt_um_JCT_PoC.v
 *
 * simple version
 */

`default_nettype none

module tt_um_JCT_PoC (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);



    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;



    reg [7:0] data_mem;
    reg [7:0] key_mem;
    reg [7:0] uo_out_r;


    reg sync1;
    reg sync2;

    wire rising_edge;


    assign rising_edge = sync1 & ~sync2;
    assign uo_out_r = data_mem ^ key_mem;
    assign uo_out = uo_out_r;

    always @(posedge clk) begin
        if (!rst_n) begin
            sync1    <= 1'b0;
            sync2    <= 1'b0;
            data_mem <= 8'b0;
            key_mem  <= 8'b0;

        end else begin


            sync1 <= uio_in[0];
            sync2 <= sync1;


            if (rising_edge) begin
                if (!uio_in[1])
                    data_mem <= ui_in;
                else
                    key_mem <= ui_in;
            end
        end
    end


  // avoid linter warning about unused pins:
    wire _unused = &{
        ena,
        uio_in[7:2],
        1'b0
    };

endmodule
