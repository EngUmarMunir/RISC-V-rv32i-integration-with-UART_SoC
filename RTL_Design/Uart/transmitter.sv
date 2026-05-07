`timescale 1ns / 1ps

module transmitter(
input logic clk,
input logic reset,
input logic bclk,
input [7:0] datain,

output logic tx_status,
output logic tx_data
);

logic [2:0] counter;
logic [7:0] TSR;

logic [1:0] state, next_state;

localparam idle  = 2'd0;
localparam start = 2'd1;
localparam data  = 2'd2;
localparam stop  = 2'd3;

// NEXT STATE LOGIC

always_comb
begin
    next_state = state;

    case(state)

        idle:
        if(bclk)
            next_state = start;

        start:
        if(bclk)
            next_state = data;

        data:
        if(bclk && counter == 3'd7)
            next_state = stop;

        stop:
        if(bclk)
            next_state = idle;

    endcase
end


// OUTPUT LOGIC

always_comb
begin
    case(state)

        idle:
        begin
            tx_data   = 1;
            tx_status = 0;
        end

        start:
        begin
            tx_data   = 0;
            tx_status = 1;
        end

        data:
        begin
            tx_data   = TSR[0];
            tx_status = 1;
        end

        stop:
        begin
            tx_data   = 1;
            tx_status = 0;
        end

        default:
        begin
            tx_data   = 1;
            tx_status = 0;
        end

    endcase
end


// SEQUENTIAL LOGIC

always_ff @(posedge clk)
begin
    if(reset)
    begin
        state   <= idle;
        counter <= 0;
        TSR     <= 0;
    end
    else
    begin
        state <= next_state;

        if(state == start && bclk)
        begin
            TSR <= datain;
            counter <= 0;
        end

        else if(state == data && bclk)
        begin
            TSR <= TSR >> 1;
            counter <= counter + 1;
        end

        else if(state == stop && bclk)
        begin
            counter <= 0;
        end
    end
end

endmodule