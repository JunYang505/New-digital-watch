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
        
    ledandkey ledAndKey (
        .clock(clock),
        .reset(reset),
        .tm_strobe(tm_strobe),
        .tm_clock(tm_clock),
        .tm_dio(tm_dio),
        .display0(display0),
        .display1(display1),
        .display2(display2),
        .display3(display3),
        .display4(display4),
        .display5(display5),
        .display6(display6),
        .display7(display7),
        .leds(leds),
        .keys(keys)
    );

    logic switchmode, timezone, up, down;
    logic settime, timereset, stop;

    assign switchmode = keys[7];
    assign timezone   = keys[6];
    assign up         = keys[5];
    assign down       = keys[4];
    assign settime    = keys[3];
    assign timereset  = keys[1];
    assign stop       = keys[0];

    // ========================================
    // Control
    // 00时钟 / 01秒表 / 10倒计时 / 11闹钟
    // ========================================
    logic control_write;
    logic [3:0] user;
    logic [1:0] ALUSrc, displaymode;
    logic [4:0] global1;
    logic timereset2;

    ControlUnit control (
        .clock(clock),
        .reset(reset),
        .switchmode(switchmode),
        .timezone(timezone),
        .up(up),
        .down(down),
        .settime(settime),
        .timereset(timereset),
        .stop(stop),
        .write(control_write),
        .user(user),
        .ALUSrc(ALUSrc),
        .global1(global1),
        .displaymode(displaymode),
        .timereset2(timereset2)
    );

    // ========================================
    // 一秒脉冲
    // ========================================
    logic one_hz;

    timed_enable #(
        .clock_count(6_000_000)
    ) one_second_timer (
        .clock(clock),
        .reset(reset),
        .enable(one_hz)
    );

    // ========================================
    // 四组时间与共享结果
    // ========================================
    logic [5:0] clock_seconds, clock_minutes;
    logic [4:0] clock_hours;

    logic [5:0] sw_seconds, sw_minutes;
    logic [4:0] sw_hours;

    logic [5:0] count_seconds, count_minutes;
    logic [4:0] count_hours;

    logic [5:0] alarm_seconds, alarm_minutes;
    logic [4:0] alarm_hours;

    logic [5:0] newseconds, newminutes;
    logic [4:0] newhours;

    logic clock_write, sw_write, count_write, alarm_write;
    logic sw_clear, count_clear;

    storage clock_storage (
        .clk(clock),
        .reset(reset),
        .write(clock_write),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .seconds(clock_seconds),
        .minutes(clock_minutes),
        .hours(clock_hours)
    );

    storage stopwatch_storage (
        .clk(clock),
        .reset(reset | sw_clear),
        .write(sw_write),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .seconds(sw_seconds),
        .minutes(sw_minutes),
        .hours(sw_hours)
    );

    storage countdown_storage (
        .clk(clock),
        .reset(reset | count_clear),
        .write(count_write),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .seconds(count_seconds),
        .minutes(count_minutes),
        .hours(count_hours)
    );

    storage alarm_storage (
        .clk(clock),
        .reset(reset),
        .write(alarm_write),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .seconds(alarm_seconds),
        .minutes(alarm_minutes),
        .hours(alarm_hours)
    );

    // ========================================
    // 独立启停
    // ========================================
    logic stop_last, stop_event;
    logic sw_running, count_running;
    logic count_finished;

    assign stop_event = stop && !stop_last;

    always_ff @(posedge clock) begin
        if (reset)
            stop_last <= 1'b0;
        else
            stop_last <= stop;
    end

    assign sw_clear =
        timereset2 && (displaymode == 2'b01);

    assign count_clear =
        timereset2 && (displaymode == 2'b10);

    always_ff @(posedge clock) begin
        if (reset) begin
            sw_running    <= 1'b0;
            count_running <= 1'b0;
        end else begin
            if (sw_clear)
                sw_running <= 1'b0;
            else if (stop_event && displaymode == 2'b01)
                sw_running <= ~sw_running;

            if (count_clear || count_finished)
                count_running <= 1'b0;
            else if (stop_event && displaymode == 2'b10)
                count_running <= ~count_running;
        end
    end

    // ========================================
    // 调度：IDLE -> 四槽位 -> IDLE
    // 编辑单独占用一个周期
    // ========================================
    typedef enum logic [2:0] {
        IDLE,
        UPDATE_CLOCK,
        UPDATE_SW,
        UPDATE_COUNT,
        CHECK_ALARM,
        EDIT
    } state_t;

    state_t state;

    logic second_pending;
    logic edit_pending;
    logic [1:0] edit_target;
    logic [3:0] edit_user;
    logic edit_request, edit_now;
    logic cancel_edit;

    assign edit_request =
        control_write && (ALUSrc == 2'b10);

    assign cancel_edit =
        (edit_target == 2'b01 && sw_clear) ||
        (edit_target == 2'b10 && count_clear);

    assign edit_now =
        (state == EDIT) && !cancel_edit;

    always_ff @(posedge clock) begin
        if (reset) begin
            state          <= IDLE;
            second_pending <= 1'b0;
            edit_pending   <= 1'b0;
            edit_target    <= 2'b00;
            edit_user      <= 4'b0000;
        end else begin
            // 保存一条编辑请求。
            if (edit_request && !edit_pending && state != EDIT) begin
                edit_pending <= 1'b1;
                edit_target  <= displaymode;
                edit_user    <= user;
            end

            case (state)
                IDLE: begin
                    if (second_pending || one_hz) begin
                        second_pending <= 1'b0;
                        state <= UPDATE_CLOCK;
                    end else if (edit_pending) begin
                        edit_pending <= 1'b0;
                        if (cancel_edit)
                            state <= IDLE;
                        else
                        state <= EDIT;
                    end
                end

                UPDATE_CLOCK: state <= UPDATE_SW;
                UPDATE_SW:    state <= UPDATE_COUNT;
                UPDATE_COUNT: state <= CHECK_ALARM;
                CHECK_ALARM:  state <= IDLE;
                EDIT:         state <= IDLE;

                default: state <= IDLE;
            endcase

            // 忙碌期间到来的秒脉冲不丢失。
            if (one_hz && state != IDLE)
                second_pending <= 1'b1;

            if (edit_pending && cancel_edit)
                edit_pending <= 1'b0;
        end
    end

    // ========================================
    // ALU 输入 MUX、操作码、写使能
    // ========================================
    logic [5:0] alu_seconds, alu_minutes;
    logic [4:0] alu_hours;
    logic [1:0] alu_ALUSrc;
    logic [3:0] alu_user;
    logic alu_zero, alu_zero2;

    always_comb begin
        alu_seconds = clock_seconds;
        alu_minutes = clock_minutes;
        alu_hours   = clock_hours;
        alu_ALUSrc  = 2'b00;
        alu_user    = 4'b0000;

        clock_write = 1'b0;
        sw_write    = 1'b0;
        count_write = 1'b0;
        alarm_write = 1'b0;

        case (state)
            UPDATE_CLOCK: begin
                // 进入时钟编辑时暂停该时钟的自动更新。
                clock_write =
                    !(displaymode == 2'b00 && ALUSrc == 2'b10);
            end

            UPDATE_SW: begin
                alu_seconds = sw_seconds;
                alu_minutes = sw_minutes;
                alu_hours   = sw_hours;

                sw_write =
                    sw_running &&
                    !sw_clear &&
                    !(stop_event && displaymode == 2'b01) &&
                    !(displaymode == 2'b01 && ALUSrc == 2'b10);
            end

            UPDATE_COUNT: begin
                alu_seconds = count_seconds;
                alu_minutes = count_minutes;
                alu_hours   = count_hours;
                alu_ALUSrc  = 2'b01;

                count_write =
                    count_running &&
                    !count_clear &&
                    !(stop_event && displaymode == 2'b10) &&
                    !(displaymode == 2'b10 && ALUSrc == 2'b10);
            end

            CHECK_ALARM: begin
                // 时钟作为主输入，闹钟作为比较参考。
                alu_ALUSrc = 2'b11;
            end

            EDIT: begin
                alu_ALUSrc = 2'b10;
                alu_user   = edit_user;

                case (edit_target)
                    2'b00: begin
                        clock_write = edit_now;
                    end

                    2'b01: begin
                        alu_seconds = sw_seconds;
                        alu_minutes = sw_minutes;
                        alu_hours   = sw_hours;
                        sw_write    = edit_now;
                    end

                    2'b10: begin
                        alu_seconds = count_seconds;
                        alu_minutes = count_minutes;
                        alu_hours   = count_hours;
                        count_write = edit_now;
                    end

                    2'b11: begin
                        alu_seconds = alarm_seconds;
                        alu_minutes = alarm_minutes;
                        alu_hours   = alarm_hours;
                        alarm_write = edit_now;
                    end
                endcase
            end

            default: ; // IDLE 不写入
        endcase

        if (reset) begin
            clock_write = 1'b0;
            sw_write    = 1'b0;
            count_write = 1'b0;
            alarm_write = 1'b0;
        end
    end

    ALU alu (
        .ALUSrc(alu_ALUSrc),
        .user(alu_user),
        .seconds(alu_seconds),
        .minutes(alu_minutes),
        .hours(alu_hours),
        .alarmseconds(alarm_seconds),
        .alarmminutes(alarm_minutes),
        .alarmhours(alarm_hours),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .zero(alu_zero),
        .zero2(alu_zero2)
    );

    assign count_finished =
        count_write &&
        (state == UPDATE_COUNT) &&
        (newhours == 0) &&
        (newminutes == 0) &&
        (newseconds == 0);

    // ========================================
    // 报警与倒计时完成提示
    // ========================================
    logic alarm_active, count_done;

    always_ff @(posedge clock) begin
        if (reset) begin
            alarm_active <= 1'b0;
            count_done   <= 1'b0;
        end else begin
            if (state == CHECK_ALARM && alu_zero2)
                alarm_active <= 1'b1;

            if (count_finished)
                count_done <= 1'b1;

            if (stop_event)
                alarm_active <= 1'b0;

            if (count_clear ||
                (stop_event && displaymode == 2'b10) ||
                (count_write && state == EDIT))
                count_done <= 1'b0;
        end
    end

    assign leds = {
        4'b0000,
        count_done,
        alarm_active,
        count_running,
        sw_running
    };

    // ========================================
    // 时区换算
    // ========================================
    logic [5:0] globaltime_raw, globaltime;

    extend timezone_extend (
        .hours({1'b0, clock_hours}),
        .global1({1'b0, global1}),
        .globaltime(globaltime_raw)
    );

    assign globaltime =
        (globaltime_raw >= 6'd24)
        ? globaltime_raw - 6'd24
        : globaltime_raw;

    // ========================================
    // 显示 MUX：与后台调度独立
    // ========================================
    logic [6:0] display_seconds, display_minutes;
    logic [5:0] display_hours;

    always_comb begin
        display_seconds = {1'b0, clock_seconds};
        display_minutes = {1'b0, clock_minutes};
        display_hours   = globaltime;

        case (displaymode)
            2'b01: begin
                display_seconds = {1'b0, sw_seconds};
                display_minutes = {1'b0, sw_minutes};
                display_hours   = {1'b0, sw_hours};
            end

            2'b10: begin
                display_seconds = {1'b0, count_seconds};
                display_minutes = {1'b0, count_minutes};
                display_hours   = {1'b0, count_hours};
            end

            2'b11: begin
                display_seconds = {1'b0, alarm_seconds};
                display_minutes = {1'b0, alarm_minutes};
                display_hours   = {1'b0, alarm_hours};
            end

            default: ;
        endcase
    end

    display display_unit (
        .second(display_seconds),
        .minute(display_minutes),
        .hour(display_hours),
        .display0(display0),
        .display1(display1),
        .display2(display2),
        .display3(display3),
        .display4(display4),
        .display5(display5),
        .display6(display6),
        .display7(display7)
    );

    
endmodule
