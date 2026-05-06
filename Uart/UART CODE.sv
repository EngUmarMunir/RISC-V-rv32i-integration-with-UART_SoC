`timescale 1ns / 1ps
// Transmitter
module transmitter(

input logic bclk,
input logic rst,send,
input logic [7:0] d_in,
output logic tx_data,
output logic tx_status
);
typedef enum logic [1:0] { IDLE, START, DATA, STOP} state;
state P_state, N_state;
logic [7:0] THR;
logic THR_full;
logic [9:0] TSR;
logic [3:0] bit_count;
always_ff @(posedge bclk or posedge rst)
begin
if(rst)
P_state <= IDLE;
else
P_state <= N_state;
end
// FSM
always_comb
begin
N_state = P_state;
case(P_state) 
 IDLE:
  begin
    if(!THR_full)
      N_state = START;
  end
 START: 
  begin
    N_state = DATA;
  end
  DATA:
   begin
     if(bit_count == 4'd8)
       N_state = STOP;
   end
  STOP:
   begin
     if(bit_count == 4'd9)
        N_state = IDLE;
   end
 endcase
 end
 // Datapath transmit
 always_ff @(posedge bclk or posedge rst)
 begin
 if(rst)
 begin
 THR <= 8'b0;
 THR_full <=1'b0;
 TSR <= 10'b1111111111;
 bit_count <=4'b0;
 tx_data <= 1'b1;
 end
 else
 begin
 case(P_state)
 IDLE:
 begin
   tx_data <=1'b1;
   bit_count <= 0;
    if(!THR_full)
     begin
      THR <= d_in;
      THR_full <=1'b1;
    end
 end
 START:
  begin
    TSR <= {1'b1, THR, 1'b0}; // TSR[9]=stop, TSR[8:1]=data, TSR[0]=start
    tx_data <= 1'b0;
    THR_full <= 1'b0;
    bit_count <= 4'b1;
  end
  DATA:
  begin
     tx_data <= TSR[bit_count];
     bit_count <=bit_count+1;
      end
  STOP:
  begin  
    tx_data <= TSR[9]; 
    bit_count <= 4'd9;
  end
  endcase
  end
 end
 assign tx_status = !THR_full;
endmodule
