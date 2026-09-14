module top(
    output logic tm_strobe,      // TM1638 Strobe
    output logic tm_clock,       // TM1638 Clock
    inout  logic tm_dio          // TM1638 Data
);

    // ! ***** Leave the part below alone (setup)
    // 6MHz clock
    /**/    logic clock;
    /**/    SB_HFOSC #(.CLKHF_DIV("0b11")) inthosc(.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clock));
    /**/
    /**/    // Startup reset for one clock
    /**/    logic reset = 1;
    /**/    always_ff @(posedge clock) begin
    /**/        reset = 0;
    /**/    end
    // ! ***** Leave the part above alone (setup)

    logic [7:0] display0, display1, display2, display3, display4, display5, display6, display7, leds;
    logic [7:0] keys;

    //    +-a-+
    //    |   |
    //    f   b
    //    |   |
    //    +-g-+
    //    |   |
    //    e   c
    //    |   |
    //    +-d-+ h
    //

             //        hgfe dcba
    logic [7:0] zero = 8'b0011_1111; // 0
    logic [7:0] one  =  8'b0000_0110; // 1

    // // ************************************************
    
    ledandkey ledAndKey(.clock(clock), .reset(reset),
                        .tm_strobe(tm_strobe), .tm_clock(tm_clock), .tm_dio(tm_dio),
                        .display0(display0),
                        .display1(display1),
                        .display2(display2),
                        .display3(display3),
                        .display4(display4),
                        .display5(display5),
                        .display6(display6),
                        .display7(display7),
                        .leds(leds),
                        .keys(keys));
    
    logic switchmode;
    logic settime;
    logic up;
    logic down;
    logic stop;

    assign switchmode = keys[7];
    assign timezone = keys[6];
    assign up = keys[5];
    assign down = keys[4];
    assign settime = keys[3];
    
    assign reset = keys[1];
    assign stop = keys[0];
    


    endmodule