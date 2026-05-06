// module for program counter
`timescale 1ns/1ps
module program_counter (
    input logic clk,
    input logic reset,
    input logic [31:0] pc_in,
    output logic [31:0] pc_out
);
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 32'b0; // reset to 0
        end else begin
            pc_out <= pc_in; // update pc_out with pc_in
        end
    end
endmodule