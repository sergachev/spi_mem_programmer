`timescale 1ns / 1ps

`include "defs.vh"

// - in a simulation, RESET comes from a testbench and CLK_TO_MEM_OUT has to be connected to the mem model via the testbench
// - in hardware, when FPGA boot memory is used, memory clock has to be connected via STARTUPE2
//   and EOS - end of startup signal - can be used as RESET

module hw_test(
        input CLK_100M,
        output [1:0] LED,

`ifndef  __SYNTHESIS__
        output CLK_TO_MEM_OUT,
        input RESET,
`endif
        inout [3:0] DQio,
        output S
    );
   
    wire clk_to_mem, clk;
    wire EOS;

`ifndef  __SYNTHESIS__
    assign CLK_TO_MEM_OUT = clk_to_mem;
`else 
    wire RESET = ~EOS;
`endif

    wire [7:0] readout;
    wire busy;
    wire error;
    reg trigger;
    reg quad;
    reg [7:0] cmd;
//    reg [23:0] addr;
    reg [(3+256)*8-1:0] data_send;
    reg [4:0] state;
    reg [31:0] cntr_blink;
    reg [1:0] LEDr;
    reg blink;
    reg startup_ready;
    
    assign LED[0] = blink & LEDr[0];  // indicates end of sequence
    assign LED[1] = ~blink & LEDr[1]; // indicates success
 
 
    clk_for_spi clk_spi_inst
      (
       .clk_in1(CLK_100M),      // input clk_in1, 100 MHz
       .clk_out1(clk),          // output clk_out1, 40 MHz, 0 deg
       .clk_out2(clk_to_mem),   // output clk_out2, 40 MHz, 180 deg
       .reset(RESET)
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
 
        qspi_mem_controller mc(
        .clk(clk), 
        .reset(RESET),
        .S(S), 
        .DQio(DQio),
        .trigger(trigger),
        .quad(quad),
        .cmd(cmd),
//        .addr(addr),
        .data_send(data_send),
        .readout(readout),
        .busy(busy),
        .error(error));



    always @(posedge clk) begin
        if(RESET) begin
            trigger <= 0;
            state <= 0;
            LEDr <= 0;
            blink <= 0;
            cntr_blink <= 'd990_000; //make some delay at startup
            startup_ready <= 0;
            quad <= 0;
        end else begin
            if(cntr_blink<'d1_000_000)
                cntr_blink <= cntr_blink+1;
            else begin
                cntr_blink <= 0;
                blink <= ~blink;
                startup_ready <= 1;
            end
        
            case(state)
                0: begin
                    if(!busy && startup_ready)
                        state <= state+1;
                end
                
                1: begin    //read memory ID to check communication
                    cmd<=`CMD_RDID;
                    trigger<=1;   
                    state <= state+1;                    
                end
                
                2: begin
                    if(trigger)
                        trigger <= 0;
                    else if(!busy) begin
                        if(readout==`JEDEC_ID) begin    //verify the memory ID read
                            LEDr[1] <= 1;
                            //enable quad IO
                            cmd <= `CMD_WRVECR;
                            data_send[7:0] <= 8'b010_01_111;  //quad protocol, hold/accelerator disabled, default drive strength
                            trigger <= 1;   
                            state <= state+1;    
                        end else
                            LEDr[0] <= 1; //mem ID wrong, error, finish
                    end
                end
                
                3: begin
                    if(trigger)
                        trigger <= 0;
                    else if(!busy) begin
                        quad <= 1;
                        cmd <= `CMD_WREN;
                        trigger <= 1;   
                        state <= state+1;    
                    end
                end
                
                4: begin
                    if(trigger)
                        trigger <= 0;
                    else if(!busy) begin
                        cmd <= `CMD_PP;
                        data_send <= {24'hA30000, 80'hDEADBEEF0000DEADBEEF, 1968'h0}; // 3 bytes of address, then data
                        trigger <= 1;   
                        state <= state+1;                    
                    end
                end

                5: begin
                    trigger <= 0;
                    if(!busy && !trigger) begin
                        LEDr[0] <= 1;
                        LEDr[1] <= ~error;
                    end
                end
                
                default:
                    state <= state+1;
            endcase
        end
    end



endmodule
