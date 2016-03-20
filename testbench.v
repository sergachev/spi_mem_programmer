`timescale 1ns / 1ps

`include "defs.vh"

module testbench();

    reg clock=0, reset=1;

    reg [31:0] data_from_PC;
    reg wr=0;
    wire [7:0] readout; 
    wire busy, error;



 //   hw_test ht(.LED(LED), .RESET(reset), .CLK_100M(clock), .C(C), .S(S),  .DQio({HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0}));
    dword_interface d1(
        .clk62(clock), .RESET(reset), .data_from_PC(data_from_PC), .wr(wr), .busy(busy), .error(error), .readout(readout),
        .C(C), .S(S),  .DQio({HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0})
    );

    N25Qxxx m1(.S(S), .C(C), .HOLD_DQ3(HOLD_DQ3), .DQ0(DQ0), .DQ1(DQ1), .Vcc('d3000), .Vpp_W_DQ2(Vpp_W_DQ2));

//    GD25Q16B m3(.sclk(C), 
//        .si(DQ0), 
//        .cs(S), 
//        .wp(Vpp_W_DQ2),
//        .hold(HOLD_DQ3),
//        .so(DQ1));


    always begin
        clock = 1; #8;
        clock = 0; #8;
    end

    reg [7:0] i;

    initial begin
        $display("TEST START");
        #605e3; //wait for mem to initialize
        reset=0;
        #16;
        while(busy) #16;
        
        $display("READ ID START", readout);
        data_from_PC = {16'd0, 8'd0, `CMD_RDID};
        wr = 1; #16; wr = 0; #16;
        while(busy) #16;
        $display("READ ID DONE: 0x%h", readout);
        
        data_from_PC = {16'd0, 8'd1, `CMD_WRVECR};
        wr = 1; #16; wr = 0; #16;
        data_from_PC = {24'b0, 8'b010_01_111}; //quad protocol, hold/accelerator disabled, default drive strength};
        wr = 1; #16; wr = 0; #16;
        while(busy) #16;
        $display("QUAD ENABLE DONE");

        data_from_PC = {16'd1, 8'd0, `CMD_WREN};
        wr = 1; #16; wr = 0; #16;
        while(busy) #16;
        $display("WRITE ENABLE DONE");

        data_from_PC = {16'd1, 8'd65, `CMD_PP};
        wr = 1; #16; wr = 0; #16;
        data_from_PC = {8'h00, 24'hABCDEF}; //the leading byte will be truncated by the width of receiving register; that's fine.
        wr = 1; #16; wr = 0; #16;
        for (i = 0; i < 64; i = i +1) begin
            data_from_PC = {i, i, i, i};
            wr = 1; #16; wr = 0; #16;
        end
        while(busy) #16;
        $display("PAGE PROGRAM DONE");
        
        
        $stop;
    end



endmodule
