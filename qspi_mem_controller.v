`timescale 1ns / 1ps

`include "defs.vh"

`define STATE_IDLE   0
`define STATE_RDID   1
`define STATE_WAIT 2
`define STATE_WREN 3
`define STATE_BE 4
`define STATE_POLL_RFSR 5
`define STATE_PP 6
`define STATE_SE 7
`define STATE_WRVECR 8


module qspi_mem_controller(
        input CLK_100M,
        input RESET,
        input trigger,
        input quad,
        input [7:0] cmd,
        input [24-1:0] addr,
        input [256*8-1:0] data_send,
        output reg [7:0] readout,
        output reg busy,
        output reg error,

        inout [3:0] DQio,
        output S
    );
    
    reg spi_trigger;
    wire spi_busy;
    
    reg [260*8-1:0] data_in;
    reg [8:0] data_in_count;
    wire [7:0] data_out;
    reg data_out_count;
    
    reg [35:0] delay_counter;
    
    spi_cmd sc(.clk(CLK_100M), .reset(RESET), .trigger(spi_trigger), .busy(spi_busy), .quad(quad),
        .data_in_count(data_in_count), .data_out_count(data_out_count), .data_in(data_in), .data_out(data_out),
        .DQio(DQio[3:0]), .S(S));
    
    
    reg [5:0] state;
    reg [5:0] nextstate;
    
    
    always @(posedge CLK_100M) begin
        if(RESET) begin
            state <= `STATE_WAIT;
            nextstate <= `STATE_IDLE;
            spi_trigger <= 0;
            busy <= 1;
            error <= 0;
            readout <= 0;
        end
        
        else
            case(state)
                `STATE_IDLE: begin
                    if(trigger) begin
                        busy <= 1;
                        error <= 0;
                        case(cmd)
                            `CMD_RDID:
                                state <= `STATE_RDID;
                            `CMD_WREN:
                                state <= `STATE_WREN;
                            `CMD_BE:
                                state <= `STATE_BE;
                            `CMD_SE:
                                state <= `STATE_SE;
                            `CMD_PP:
                                state <= `STATE_PP;
                            `CMD_WRVECR:
                                state <= `STATE_WRVECR;
                        endcase
                    end else
                        busy <= 0;
                end
            
                `STATE_RDID: begin
                    data_in <= `CMD_RDID;
                    data_in_count <= 1;
                    data_out_count <= 1;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_IDLE;
                end                

                `STATE_WRVECR: begin
                    data_in <= {`CMD_WRVECR, data_send[7:0]};
                    data_in_count <= 2;
                    data_out_count <= 0;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_IDLE;
                end

                `STATE_WREN: begin
                    data_in <= `CMD_WREN;
                    data_in_count <= 1;
                    data_out_count <= 0;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_IDLE;
                end

                `STATE_BE: begin
                    data_in <= `CMD_BE;
                    data_in_count <= 1;
                    data_out_count <= 0;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_POLL_RFSR;
                    delay_counter <= `tBEmax*`input_freq;
                end

                `STATE_POLL_RFSR: begin
                    if(delay_counter == 0) begin // max delay timeout
                        state <= `STATE_IDLE;
                        error <= 1;
                    end else begin
                        if(readout[7]==1)  begin// operation finished successfully
                            state <= `STATE_IDLE;
                        end else begin //go on polling
                            data_in <= `CMD_RFSR;
                            data_in_count <= 1;
                            data_out_count <= 1;
                            spi_trigger <= 1;
                            delay_counter <= delay_counter - 1;
                            state <= `STATE_WAIT;
                            nextstate <= `STATE_POLL_RFSR;
                        end
                    end
                end                

                `STATE_WAIT: begin
                    spi_trigger <= 0;
                    if(!spi_trigger && !spi_busy) begin
                        state <= nextstate;
                        readout <= data_out;
                    end
                end
                
                `STATE_PP: begin
                    data_in <= {`CMD_PP, addr, data_send};
                    data_in_count <= 260; //256 for data +1cmd+3addr
                    data_out_count <= 0;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_POLL_RFSR;               
                    delay_counter <= `tPPmax*`input_freq;
               end

                `STATE_SE: begin
                    data_in <= {`CMD_SE, addr};
                    data_in_count <= 4; //1cmd+3addr
                    data_out_count <= 0;
                    spi_trigger <= 1;
                    state <= `STATE_WAIT;
                    nextstate <= `STATE_POLL_RFSR;               
                    delay_counter <= `tSEmax*`input_freq;
               end
                
            endcase
    end
    
    
endmodule
