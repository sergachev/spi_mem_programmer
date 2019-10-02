`timescale 1ns / 1ps

module testbench();
    reg clk = 0, rst = 1;
    wire [1:0] LED;
    
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    initial begin
        $display("SIM START");
        #605e3; // wait for the memory to initialize
        rst = 0;
        #10;
        while(!LED[0]) #10;
        $display("SIM END: %d", LED[1]);
        $stop;
    end

    wire clk_to_mem, S, HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0;

    hw_test ht (
        .LED(LED),
        .rst(rst),
        .CLK_100M(clk),
        .clk_to_mem_out(clk_to_mem),
        .S(S),
        .DQio({HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0})
    );
    
    N25Qxxx m1 (
        .S(S),
        .C_(clk_to_mem),
        .HOLD_DQ3(HOLD_DQ3),
        .DQ0(DQ0),
        .DQ1(DQ1),
        .Vcc('d3000),
        .Vpp_W_DQ2(Vpp_W_DQ2)
    );

//    s25fl128l m1 (
//        .SI(DQ0),
//        .SO(DQ1),
//        .SCK(clk_to_mem),
//        .CSNeg(S),
//        .WPNeg(Vpp_W_DQ2),
//        .IO3_RESETNeg(HOLD_DQ3)
//    );

//    GD25Q16B m1 (
//        .sclk(clk_to_mem),
//        .si(DQ0),
//        .cs(S),
//        .wp(Vpp_W_DQ2),
//        .hold(HOLD_DQ3),
//        .so(DQ1)
//    );

endmodule
