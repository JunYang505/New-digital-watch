/*
module ALU_tb ();
    logic [1:0]ALUSrc;
    logic zero;
    logic zero2;

    logic [3:0]user;

    logic [5:0]seconds;
    logic [5:0]minutes;
    logic [4:0]hours;

    logic [5:0]alarmseconds;
    logic [5:0]alarmminutes;
    logic [4:0]alarmhours;

    logic [5:0]newseconds;
    logic [5:0]newminutes;
    logic [4:0]newhours;

    integer errors;

ALU dut (
    .ALUSrc(ALUSrc),
    .zero(zero),
    .zero2(zero2),
    .user(user),
    .seconds(seconds),
    .minutes(minutes),
    .hours(hours),

    .alarmseconds(alarmseconds),
    .alarmminutes(alarmminutes),
    .alarmhours(alarmhours),

    .newseconds(newseconds),
    .newminutes(newminutes),
    .newhours(newhours)
);

initial begin

    ALUSrc = 2'b00;
    user = 5'b0000;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    alarmseconds = 6'd0;
    alarmminutes = 6'd0;
    alarmhours = 5'd0;

    errors = 0;


    #10;
    //test +
    user = 5'b0000;
    ALUSrc = 2'b00;
    seconds = 6'd59;
    minutes = 6'd59;
    hours = 5'd23;
    
    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd 0) || (newhours != 5'd0) ) begin
        errors = errors + 1; 
        $display("wrong 1"); 
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0000;
    ALUSrc = 2'b00;
    seconds = 6'd59;
    minutes = 6'd10;
    hours = 5'd10;

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd11) || (newhours != 5'd10)) begin
        errors = errors + 1; 
        $display("wrong 2"); 
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0000;
    ALUSrc = 2'b00;
    seconds = 6'd0;
    minutes = 6'd59;
    hours = 5'd10;

    #10;

    if ((newseconds != 6'd1) || (newminutes != 6'd59) || (newhours != 5'd10) ) begin
        errors = errors + 1; 
        $display("wrong 3"); 
        $display(newseconds,"",newminutes,"",newhours);end
    //test -
    user = 5'b0000;
    ALUSrc = 2'b01;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd10;

    #10;

    if ((newseconds != 6'd59) || (newminutes != 6'd59) || (newhours != 5'd9) ) begin
        errors = errors + 1; 
        $display("wrong 4");
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0000;
    ALUSrc = 2'b01;
    seconds = 6'd10;
    minutes = 6'd23;
    hours = 5'd9;

    #10;

    if ((newseconds != 6'd9) || (newminutes != 6'd23) || (newhours != 5'd9 )) begin
        errors = errors + 1; 
        $display("wrong 5"); 
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0000;
    ALUSrc = 2'b01;
    seconds = 6'd1;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd0) || (newhours != 5'd0 || (zero == 1'b1) )) begin
        errors = errors + 1;
        $display("wrong 6"); 
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0000;
    ALUSrc = 2'b01;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd0) || (newhours != 5'd0) ) begin
        errors = errors + 1; 
        $display("wrong 7");
        $display(newseconds,"",newminutes,"",newhours,"",zero);end

    // set up
    user = 5'b0010;
    ALUSrc = 2'b10;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd1) || (newminutes != 6'd0) || (newhours != 5'd0) ) begin
        errors = errors + 1; 
        $display("wrong 8");
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0100;
    ALUSrc = 2'b10;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;
    

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd1) || (newhours != 5'd0) ) begin
        errors = errors + 1; 
        $display("wrong 9");
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b1000;
    ALUSrc = 2'b10;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd0) || (newhours != 5'd1) ) begin
        errors = errors + 1; 
        $display("wrong 10");
        $display(newseconds,"",newminutes,"",newhours);end
    // down
    user = 5'b0011;
    ALUSrc = 2'b10;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd59) || (newminutes != 6'd0) || (newhours != 5'd0) ) begin
        errors = errors + 1; 
        $display("wrong 11");
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b0101;
    ALUSrc = 2'b10;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd59) || (newhours != 5'd0) ) begin
        errors = errors + 1; 
        $display("wrong 12");
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b1001;
    ALUSrc = 2'b10;
    seconds = 6'd0;
    minutes = 6'd0;
    hours = 5'd0;

    #10;

    if ((newseconds != 6'd0) || (newminutes != 6'd0) || (newhours != 5'd23) ) begin
        errors = errors + 1; 
        $display("wrong 13");
        $display(newseconds,"",newminutes,"",newhours);end

    user = 5'b1001;
    ALUSrc = 2'b11;
    seconds = 6'd1;
    minutes = 6'd45;
    hours = 5'd8;

    alarmseconds = 6'd1;
    alarmminutes = 6'd45;
    alarmhours = 5'd8;
    #10;

    if (zero2 != 1) begin
        errors = errors + 1; 
        $display("wrong 14");
        $display(zero2);end

 user = 5'b1001;
    ALUSrc = 2'b11;
    seconds = 6'd1;
    minutes = 6'd45;
    hours = 5'd8;

    alarmseconds = 6'd0;
    alarmminutes = 6'd45;
    alarmhours = 5'd8;
    #10;

    if (zero2 != 0) begin
        errors = errors + 1; 
        $display("wrong 15");
        $display(zero2);end


    

    $display("There are",errors," errors" );
    $finish;



end

endmodule */

module ALU_tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic [1:0] ALUSrc;
    logic [3:0] user;

    logic [5:0] seconds, minutes;
    logic [4:0] hours;

    logic [5:0] alarmseconds, alarmminutes;
    logic [4:0] alarmhours;

    logic [5:0] newseconds, newminutes;
    logic [4:0] newhours;
    logic zero, zero2;

    int tests = 0;
    int errors = 0;

    localparam int SECONDS_PER_DAY = 24 * 60 * 60;

    ALU dut (
        .ALUSrc(ALUSrc),
        .user(user),
        .seconds(seconds),
        .minutes(minutes),
        .hours(hours),
        .alarmseconds(alarmseconds),
        .alarmminutes(alarmminutes),
        .alarmhours(alarmhours),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .zero(zero),
        .zero2(zero2)
    );

    
    task automatic reference_model(
        input int mode,
        input int command,
        input int t,
        input int alarm_t,
        output int expected_t,
        output bit expected_zero,
        output bit expected_zero2
    );
        int h, m, s;
        int direction;

        h = t / 3600;
        m = (t / 60) % 60;
        s = t % 60;

        expected_t = t;
        expected_zero = 0;
        expected_zero2 = 0;

        case (mode)
            0: begin
                expected_t = (t + 1) % SECONDS_PER_DAY;
            end

            1: begin
             
                expected_t = (t == 0) ? 0 : t - 1;
                expected_zero = (t == 0);
            end

            2: begin
                direction = (command & 1) ? -1 : 1;


                case (command >> 1)
                    1: s = (s + direction + 60) % 60;
                    2: m = (m + direction + 60) % 60;
                    4: h = (h + direction + 24) % 24;
                    default: ; 
                endcase

                expected_t = h * 3600 + m * 60 + s;
            end

            3: begin
                expected_zero2 = (t == alarm_t);
            end
        endcase
    endtask

    task automatic check_case(
        input int mode,
        input int command,
        input int t,
        input int alarm_t
    );
        int expected_t;
        bit expected_zero, expected_zero2;

        logic [5:0] expected_s, expected_m;
        logic [4:0] expected_h;

        ALUSrc = mode;
        user = command;

        hours   = t / 3600;
        minutes = (t / 60) % 60;
        seconds = t % 60;

        alarmhours   = alarm_t / 3600;
        alarmminutes = (alarm_t / 60) % 60;
        alarmseconds = alarm_t % 60;

        reference_model(
            mode, command, t, alarm_t,
            expected_t, expected_zero, expected_zero2
        );

        expected_h = expected_t / 3600;
        expected_m = (expected_t / 60) % 60;
        expected_s = expected_t % 60;

        #1;
        tests++;



        if (((mode != 3) &&
             ({newhours, newminutes, newseconds} !==
              {expected_h, expected_m, expected_s})) ||
            (zero  !== expected_zero) ||
            (zero2 !== expected_zero2)) begin

            errors++;


            if (errors <= 20) begin
                $display(
                    "FAIL #%0d mode=%02b user=%04b input=%02d:%02d:%02d alarm=%02d:%02d:%02d",
                    tests, ALUSrc, user,
                    hours, minutes, seconds,
                    alarmhours, alarmminutes, alarmseconds
                );

                $display(
                    "  got      %02d:%02d:%02d zero=%b zero2=%b",
                    newhours, newminutes, newseconds, zero, zero2
                );

                $display(
                    "  expected %02d:%02d:%02d zero=%b zero2=%b",
                    expected_h, expected_m, expected_s,
                    expected_zero, expected_zero2
                );
            end
        end
    endtask

    initial begin
     
        for (int t = 0; t < SECONDS_PER_DAY; t++) begin
            check_case(0, 0, t, 0);
            check_case(1, 0, t, 0);
        end

        for (int t = 0; t < SECONDS_PER_DAY; t++) begin
            for (int command = 0; command < 16; command++) begin
                check_case(2, command, t, 0);
            end
        end

        for (int t = 0; t < SECONDS_PER_DAY; t++) begin
            check_case(3, 0, t, t);

            check_case(
                3, 0, t,
                (t / 60) * 60 + ((t % 60 + 1) % 60)
            );

            check_case(
                3, 0, t,
                (t / 3600) * 3600
                + (((t / 60) % 60 + 1) % 60) * 60
                + t % 60
            );

            check_case(
                3, 0, t,
                ((t / 3600 + 1) % 24) * 3600 + t % 3600
            );
        end


        check_case(1, 0, 0, 0);
        check_case(0, 0, 100, 0);

        check_case(3, 0, 100, 100);
        check_case(0, 0, 100, 0);

 
        repeat (10000) begin
            check_case(
                $urandom_range(0, 3),
                $urandom_range(0, 15),
                $urandom_range(0, SECONDS_PER_DAY - 1),
                $urandom_range(0, SECONDS_PER_DAY - 1)
            );
        end

        if (errors == 0) begin
            $display("PASS: %0d cases", tests);
            $finish;
        end else begin
            $fatal(1, "FAIL: %0d / %0d cases failed", errors, tests);
        end
    end
endmodule
