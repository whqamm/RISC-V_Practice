//Author: WangHuiquan

`include "timescale.v"
`include "define.h"

module test_MyRisc;

    reg clk = 1'b0;
    always clk = #20 ~clk;
    
    reg rst;
    
    riscv_cpu_top riscv_tb(.clk_i(clk), .rst_i(rst));
    
    initial
    begin
        rst = 1'b1;
        #70;
        rst = 1'b0;
        #8000;
        $stop;
    end

endmodule
