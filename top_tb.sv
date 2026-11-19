`timescale 1ns/1ps


module SB_HFOSC #(
    parameter CLKHF_DIV = "0b11"
) (
    input  wire CLKHFPU,
    input  wire CLKHFEN,
    output reg  CLKHF
);
    initial CLKHF = 1'b0;

    always #5 begin
        if (CLKHFPU && CLKHFEN)
            CLKHF = ~CLKHF;
        else
            CLKHF = 1'b0;
    end
endmodule


module top_tb;

    wire tm_strobe;
    wire tm_clock;
    tri  tm_dio;

    reg [7:0] test_keys;
    reg test_tick;

    integer tests;
    integer errors;

    top dut (
        .tm_strobe(tm_strobe),
        .tm_clock(tm_clock),
        .tm_dio(tm_dio)
    );

    task automatic wait_cycles(input integer n);
        repeat (n)
            @(negedge dut.clock);
    endtask


    task automatic press_key(input integer key_index);
        @(negedge dut.clock);
        test_keys = 8'b0000_0000;
        test_keys[key_index] = 1'b1;

        wait_cycles(12);
        test_keys = 8'b0000_0000;

        wait_cycles(12);
    endtask



    task automatic tick_once;
        @(negedge dut.clock);
        test_tick = 1'b1;

        @(negedge dut.clock);
        test_tick = 1'b0;

        wait_cycles(12);
    endtask

    task automatic check_time(
        input integer target,
        input integer expected_h,
        input integer expected_m,
        input integer expected_s,
        input string label
    );
        reg [4:0] got_h;
        reg [5:0] got_m;
        reg [5:0] got_s;

        begin
            case (target)
                0: begin
                    got_h = dut.clock_hours;
                    got_m = dut.clock_minutes;
                    got_s = dut.clock_seconds;
                end

                1: begin
                    got_h = dut.sw_hours;
                    got_m = dut.sw_minutes;
                    got_s = dut.sw_seconds;
                end

                2: begin
                    got_h = dut.count_hours;
                    got_m = dut.count_minutes;
                    got_s = dut.count_seconds;
                end

                3: begin
                    got_h = dut.alarm_hours;
                    got_m = dut.alarm_minutes;
                    got_s = dut.alarm_seconds;
                end

                default: begin
                    got_h = 'x;
                    got_m = 'x;
                    got_s = 'x;
                end
            endcase

            tests = tests + 1;

            if ((got_h !== expected_h) ||
                (got_m !== expected_m) ||
                (got_s !== expected_s)) begin

                errors = errors + 1;

                $display(
                    "FAIL: %s got=%02d:%02d:%02d expected=%02d:%02d:%02d",
                    label,
                    got_h, got_m, got_s,
                    expected_h, expected_m, expected_s
                );
            end else begin
                $display(
                    "PASS: %s time=%02d:%02d:%02d",
                    label, got_h, got_m, got_s
                );
            end
        end
    endtask

    task automatic check_flag(
        input logic actual,
        input logic expected,
        input string label
    );
        tests = tests + 1;

        if (actual !== expected) begin
            errors = errors + 1;
            $display(
                "FAIL: %s got=%b expected=%b",
                label, actual, expected
            );
        end else begin
            $display("PASS: %s", label);
        end
    endtask


    initial begin
        tests = 0;
        errors = 0;

        test_keys = 0;
        test_tick = 0;

       
        force dut.keys = test_keys;
        force dut.one_hz = test_tick;

   
        force dut.reset = 1'b1;
        wait_cycles(5);
        release dut.reset;
        wait_cycles(12);


        check_time(0, 0, 0, 0, "clock reset");
        check_time(1, 0, 0, 0, "stopwatch reset");
        check_time(2, 0, 0, 0, "countdown reset");
        check_time(3, 0, 0, 0, "alarm reset");

      
        wait_cycles(100);
        check_time(0, 0, 0, 0, "idle does not advance time");

。
        repeat (3)
            tick_once();

        check_time(0, 0, 0, 3, "clock advances three seconds");
        check_time(1, 0, 0, 0, "stopped stopwatch stays unchanged");
        check_time(2, 0, 0, 0, "stopped countdown stays unchanged");
        check_time(3, 0, 0, 0, "alarm setting stays unchanged");

 
        press_key(7); 

        check_flag(
            dut.displaymode == 2'b01,
            1'b1,
            "switch to stopwatch"
        );

        press_key(0); 
        check_flag(dut.sw_running, 1'b1, "start stopwatch");

        repeat (2)
            tick_once();

        check_time(0, 0, 0, 5, "clock continues with stopwatch");
        check_time(1, 0, 0, 2, "stopwatch advances two seconds");

     
        press_key(0);
        check_flag(dut.sw_running, 1'b0, "pause stopwatch");

        tick_once();

        check_time(0, 0, 0, 6, "clock continues during pause");
        check_time(1, 0, 0, 2, "paused stopwatch holds");


        press_key(7); 
        press_key(3);

        repeat (3)
            press_key(5); 

        check_time(2, 0, 0, 3, "edit countdown to three seconds");
        check_time(1, 0, 0, 2, "editing does not change stopwatch");

        
        repeat (3)
            press_key(3);

        press_key(0); 
        check_flag(dut.count_running, 1'b1, "start countdown");

 
        press_key(7); 

        tick_once();
        check_time(2, 0, 0, 2, "countdown runs in background");

        tick_once();
        check_time(2, 0, 0, 1, "countdown reaches one second");

        tick_once();
        check_time(2, 0, 0, 0, "countdown reaches zero");
        check_flag(dut.count_running, 1'b0, "countdown stops at zero");
        check_flag(dut.count_done, 1'b1, "countdown completion flag");

        tick_once();
        check_time(2, 0, 0, 0, "countdown does not underflow");
        check_time(0, 0, 0, 10, "clock completed ten ticks");

  
        press_key(3); 
        press_key(3); 
        press_key(5); 

        check_time(3, 0, 1, 0, "edit alarm minute");
        check_time(0, 0, 0, 10, "alarm edit leaves clock unchanged");
        check_time(1, 0, 0, 2, "alarm edit leaves stopwatch unchanged");

        repeat (2)
            press_key(3); 

    
        press_key(7); 
        press_key(6); 

        check_flag(dut.global1 == 5'd1, 1'b1, "timezone offset");
        check_flag(
            dut.display_hours == 6'd1,
            1'b1,
            "timezone changes displayed hour"
        );
        check_time(0, 0, 0, 10, "timezone leaves base clock unchanged");

        wait_cycles(100);
        check_time(0, 0, 0, 10, "idle holds after operations");

        if (errors == 0) begin
            $display("ALL PASS: %0d checks", tests);
            $finish;
        end else begin
            $fatal(1, "%0d / %0d checks failed", errors, tests);
        end
    end

 
    initial begin
        #1_000_000;
        $fatal(1, "Simulation timeout");
    end

endmodule


module SB_IO #(
    parameter [5:0] PIN_TYPE = 6'b000000,
    parameter PULLUP = 1'b0,
    parameter NEG_TRIGGER = 1'b0,
    parameter IO_STANDARD = "SB_LVCMOS"
) (
    inout  wire PACKAGE_PIN,
    input  wire OUTPUT_ENABLE,
    input  wire D_OUT_0,
    output wire D_IN_0
);

    assign PACKAGE_PIN =
        OUTPUT_ENABLE ? D_OUT_0 : 1'bz;

    assign D_IN_0 = PACKAGE_PIN;

endmodule
