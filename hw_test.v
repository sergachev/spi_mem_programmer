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
    reg [(3+256)*8-1:0] data_send;
    reg [4:0] state;
    reg [1:0] LEDr;
    reg blink;
    
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
            quad <= 0;
        end else begin
            blink <= ~blink;
        
            case(state)
                0: begin
                    if(!busy)
                        state <= state+1;
                end
                
                1: begin    // read memory ID to check communication
                    cmd <= `CMD_RDID;
                    trigger <= 1;   
                    state <= state+1;                    
                end
                
                2: begin
                    if (trigger)
                        trigger <= 0;
                    else if(!busy) begin
                        if (readout == `JEDEC_ID) begin // verify the memory ID read
                            LEDr[1] <= 1;
                            // enable quad IO
                            cmd <= `CMD_WRVECR;
                            data_send[7:0] <= 8'b010_01_111;  // quad protocol, hold/accelerator disabled, default drive strength
                            trigger <= 1;   
                            state <= state+1;    
                        end else
                            LEDr[0] <= 1; // memory ID is wrong, error, finish
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
                         // 3 bytes of address, then random data
                        data_send <= {24'hA30000, 2048'h01020304057372f04a39e4d37746533f26c5e18660ac4f512a18faef74279aae5f886745368ff4bdc0505deeb822c1c2a0ac568c4c11b41a9f62f93492cdbdb2a2b57f16c173a319879b8e45baee122f7c5821445ae1ad29f7e2655ac509ca8b450d453638de42e853adb1fbbcc9bac5f7f35b16346431aa0ac6f4865abaa74859cdf4d94c46b40efabe211621515d5dc2d383debab44cdbd57c41b37c34d6466f15cf7e36b481e104bf0367d7f7393fe2e62f489e8c9f6c522ec842789e8b6d251d35cb938664fda91a44de72227f9d748dacc21bc0e5ad5df3458e8f3b023e4e53cb4b266d0fb495aaeae3a56f04f9a1117409992975c4b4a5a88048edee5d};
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
