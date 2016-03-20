`timescale 1ns / 1ps


module testbench();

    reg clock=0, reset=1;

    always begin
        clock = 1; #5;
        clock = 0; #5;
    end

    initial begin
        $display("TEST START");
        #605e3; //wait for mem to initialize
        reset=0;
        #10;
        while(!LED[0])
            #10;
        $display("TEST DONE");
        $stop;
    end


    wire [1:0] LED;
    hw_test ht(.LED(LED), .RESET(reset), .CLK_100M(clock), .C(C), .S(S),  .DQio({HOLD_DQ3, Vpp_W_DQ2, DQ1, DQ0}));

    N25Qxxx m1(.S(S), .C(C), .HOLD_DQ3(HOLD_DQ3), .DQ0(DQ0), .DQ1(DQ1), .Vcc('d3000), .Vpp_W_DQ2(Vpp_W_DQ2));

//    GD25Q16B m3(.sclk(C), 
//        .si(DQ0), 
//        .cs(S), 
//        .wp(Vpp_W_DQ2),
//        .hold(HOLD_DQ3),
//        .so(DQ1));



endmodule
