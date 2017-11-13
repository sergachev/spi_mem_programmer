`timescale 1ns / 1ps


module testbench();
    
    reg clock=0, reset=1;
    wire [1:0] LED;
    
    always begin
        clock = 1; #5;
        clock = 0; #5;
    end

    initial begin
        $display("TEST START");
        #605e3; // wait for the memory to initialize
        reset=0;
        #10;
        while(!LED[0])
            #10;
        $display("TEST DONE");
        $stop;
    end

    wire clk_to_mem, S, HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0;

    hw_test ht(.LED(LED), .RESET(reset), .CLK_100M(clock), .CLK_TO_MEM_OUT(clk_to_mem), .S(S),  .DQio({HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0}));
    
    N25Qxxx m1(.S(S), .C_(clk_to_mem), .HOLD_DQ3(HOLD_DQ3), .DQ0(DQ0), .DQ1(DQ1), .Vcc('d3000), .Vpp_W_DQ2(Vpp_W_DQ2));

    //other memory models
    //s25fl128l m2(.SI(DQ0), .SO(DQ1), .SCK(clk_to_mem), .CSNeg(S), .WPNeg(Vpp_W_DQ2), .IO3RESETNeg(HOLD_DQ3));

//    GD25Q16B m3(.sclk(clk_to_mem), 
//        .si(DQ0), 
//        .cs(S), 
//        .wp(Vpp_W_DQ2),
//        .hold(HOLD_DQ3),
//        .so(DQ1));
    
    

endmodule
