// Top-level module for the SoC
// instantiates the core, instruction memory, memory mapping unit,
`timescale 1ps/1ps
module soc_top (
    input logic clk,
    input logic reset,
    output logic uart_tx,
    output logic [31:0] pc_out
);

logic [31:0] inst_mem_out;
logic [31:0] data_addr;
logic [31:0] data_w;
logic [31:0] data_r;
logic mem_write_en;

inst_mem instruction_memory (
    .read_addr(pc_out),
    .inst_out(inst_mem_out)
);

riscv_core processor_core (
    .clk(clk),
    .reset(reset),
    .inst_mem_out(inst_mem_out),
    .data_r(data_r),
    .pc_out(pc_out),
    .data_addr(data_addr),
    .data_w(data_w),
    .mem_write_en(mem_write_en)
);

memory_mapping_unit memory_map (
    .clk(clk),
    .reset(reset),
    .addr(data_addr),
    .write_data(data_w),
    .mem_write_en(mem_write_en),
    .read_data(data_r),
    .uart_tx(uart_tx)
);
endmodule
