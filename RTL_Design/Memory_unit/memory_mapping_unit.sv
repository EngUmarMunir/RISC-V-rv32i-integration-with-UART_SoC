// Memory-mapped data memory and UART-TX routing.
`timescale 1ns/1ps
module memory_mapping_unit (
    input logic clk,
    input logic reset,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    input logic mem_write_en,
    output logic [31:0] read_data,
    output logic uart_tx
);

localparam logic [31:0] UartDataAddr = 32'd1600;
localparam logic [31:0] UartStatusAddr = 32'd1604;

logic [31:0] data_mem_r;
logic data_mem_write_en;
logic tx_status;
logic [7:0] uart_datain;
logic uart_bclk;
logic [3:0] uart_bclk_count;
logic uart_write_accepted;

assign data_mem_write_en = mem_write_en && (addr < UartDataAddr);
assign uart_write_accepted = mem_write_en && (addr == UartDataAddr) &&
                             (uart_bclk_count == 4'd0) && (tx_status == 1'b0);
assign uart_datain = write_data[7:0];
assign uart_bclk = (uart_bclk_count != 4'd0);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        uart_bclk_count <= 4'd0;
    end else begin
        if (uart_write_accepted) begin
            uart_bclk_count <= 4'd11;
        end else if (uart_bclk_count != 4'd0) begin
            uart_bclk_count <= uart_bclk_count - 4'd1;
        end
    end
end

data_mem data_memory (
    .clk(clk),
    .rest(reset),
    .addr(addr),
    .data_w(write_data),
    .mem_write_en(data_mem_write_en),
    .MemRead(1'b1),
    .data_r(data_mem_r)
);

transmitter uart_transmitter (
    .clk(clk),
    .reset(reset),
    .bclk(uart_bclk),
    .datain(uart_datain),
    .tx_status(tx_status),
    .tx_data(uart_tx)
);

always_comb begin
    if (addr == UartStatusAddr) begin
        read_data = {31'b0, tx_status};
    end else if (addr == UartDataAddr) begin
        read_data = 32'b0;
    end else begin
        read_data = data_mem_r;
    end
end

endmodule
