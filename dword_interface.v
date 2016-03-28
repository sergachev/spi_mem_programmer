`timescale 1ns / 1ps

`include "defs.vh"

// - in simulation, reset comes from testbench and C has to be connected mem model via testbench
// - in hardware, when FPGA boot memory is used, memory clock has to be connected via STARTUPE2
//   (and also EOS - end of startup signal can be used as reset)

module dword_interface(
        input clk_in,
        input reset,
        input wr,
        input [31:0] data_from_PC,
        output reg busy, 
        output error,
        output [7:0] readout,

        inout [3:0] DQio,
        //output C,
        output S
    );
   
    wire clk_to_mem, clk_spi;
  //  wire reset = ~EOS;
  //  assign C = clk_to_mem;
        
    wire EOS;
 
 
    clk_for_spi clk_spi_inst
      (
       .clk_in1(clk_in),       // input clk_in1,   62.5MHz
       .clk_out1(clk_spi),     // output clk_out1, half input freq
       .clk_out2(clk_to_mem),  // output clk_out2, clk_out1 inverted
       .reset(reset)           // input reset       
    );      

    STARTUPE2 #(
       .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
       .SIM_CCLK_FREQ(10.0)  // Set the Configuration Clock Frequency(ns) for simulation.
    )
    STARTUPE2_inst (
        .CFGCLK(),              // 1-bit output: Configuration main clock output
        .CFGMCLK(),             // 1-bit output: Configuration internal oscillator clock output
        .EOS(EOS),              // 1-bit output: Active high output signal indicating the End Of Startup.
        .PREQ(),                // 1-bit output: PROGRAM request to fabric output
        .CLK(1'b0),             // 1-bit input: User start-up clock input
        .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
        .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
        .KEYCLEARB(1'b0),       // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
        .PACK(1'b0),             // 1-bit input: PROGRAM acknowledge input
        .USRCCLKO(clk_to_mem),   // 1-bit input: User CCLK input
        .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
        .USRDONEO(1'b1),   // 1-bit input: User DONE pin output control
        .USRDONETS(1'b1)  // 1-bit input: User DONE 3-state enable output
    );
 
    reg [3:0] state;
    reg trigger;
    reg quad;
    reg [7:0] cmd;
    reg [259*8-1:0] data_send;
    reg [7:0] len;
    wire mc_busy;


    qspi_mem_controller mc(
    .clk(clk_spi), 
    .reset(reset),
    .S(S), 
    .DQio(DQio),
    .trigger(trigger),
    .quad(quad),
    .cmd(cmd),
    .data_send(data_send),
    .readout(readout),
    .busy(mc_busy),
    .error(error));


    always @(posedge clk_in) begin
        if(reset) begin
            trigger <= 0;
            state <= 0;
            quad <= 0;
            busy <= 1;
        end else begin
        
            case(state)
                0: begin
                    trigger <= 0;
                    if(busy && !mc_busy) begin
                        busy <= 0;
                    end else begin
                        if(!busy && wr) begin
                            busy <= 1;
                            cmd <= data_from_PC[7:0];
                            len <= data_from_PC[15:8];
                            quad <= data_from_PC[16];
                            state <= state+1;
                        end
                    end
                end
            
                1: begin
                    if(len>0) begin
                        if(wr) begin
                            data_send <= {data_send[259*8-1-32:0], data_from_PC};
                            len <= len-1;
                        end
                    end else begin
                        trigger <= 1;
                        state <= state+1;
                    end
                end
                
                2: begin
                    state <= 0; //holding trigger 1 more cycle as target clock is twice slower
                end
                
                default:
                    state <= state+1;
            endcase
        end
    end



endmodule
