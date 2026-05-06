// module of memory mapping unit
// Instation data memory and uart transmitter(transmitter.sv) are connected to the core through this module
`timescale 1ns/1ps
module memory_mapping_unit (
input logic clk,
input logic reset,
input logic [31:0] inst_mem_out,
input logic 
output logic [31:0] pc_out,

);




// instiation of data memory
    logic mem_write_en,
    logic MemRead,
    logic [31:0] data_r,
data_mem data_memory (

        .clk(clk),
        .rest(reset),
        .addr(addr),
        .data_w(write_data),
        .mem_write_en(mem_write_en),
        .MemRead(MemRead),
        .data_r(data_r)
    );

// transmitter instantiation
logic bclk;
logic [7:0] datain;
logic tx_status;
logic tx_data;
transmitter uart_transmitter (
    .clk(clk),
    .reset(reset),
    .bclk(bclk),
    .datain(datain),
    .tx_status(tx_status),
    .tx_data(tx_data)
);
endmodule
