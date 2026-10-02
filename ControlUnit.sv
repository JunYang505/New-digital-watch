/*module ControlUnit (
    input logic clock,
    input logic reset

    input logic switchmode,
    input logic timezone,
    input logic up,
    input logic down,
    input logic settime,
    
    input logic timereset,
    input logic stop

    output logic write,
    output logic [3:0]user,
    output logic [1:0]ALUSrc,
    output logic [4:0]global1,
    output logic [1:0]displaymode,
    output logic timereset2
);
    logic switchmode_detected;
    logic timezone_detected;
    logic up_detected;
    logic down_detected;
    logic settime_detected;
    logic timereset_detected;
    logic stop_detected;

    logic [1:0] mode;

    risingedge_detector up_press(.in(switchmode), .detected(switchmode_detected), .clock(clock), .reset(reset));
    risingedge_detector up_press(.in(timezone), .detected(timezone_detected), .clock(clock), .reset(reset));
    risingedge_detector up_press(.in(up), .detected(up_detected), .clock(clock), .reset(reset));
    risingedge_detector up_press(.in(down), .detected(down_detected), .clock(clock), .reset(reset));
    risingedge_detector up_press(.in(settime), .detected(settime_detected), .clock(clock), .reset(reset));
    risingedge_detector up_press(.in(timereset), .detected(timereset_detected), .clock(clock), .reset(reset));
    risingedge_detector up_press(.in(stop), .detected(stop_detected), .clock(clock), .reset(reset));

    assign write = 1;

    always_ff @(posedge clock, posedge reset) begin
        if (reset) begin
            write <= 1'b0;
            user <= 3'd0;
            ALUSrc <= 2'd0;
            global1 <= 5'd0;
            displaymode <= 2'd0;
        
        end else begin

            if (switchmode) begin
                if (mode == 2'b00) begin     
                    mode <= 2'b11;
                end else begin
                    mode <= mode + 1;
                end

            end else if (timezone) begin
                    if (global1 == 5'd24 ) begin
                        global1 <= 5'd0;
                    end else begin
                        global1 <= global1 + 1;
                    end

            end else if (settime) begin
                    if (up && !down) begin
                   
                    user[0] <= 1;

                    end else if (down && !up) begin                    
                    user[0] <= 0;

                    end else begin
                        user[0] <= 0;
                    end

            end else if (timereset && (mode != 2'b00) && (mode != 2'b11)) begin
                timereset2 <= 1;

            end else if (stop && (mode != 2'b00) && (mode != 2'b11)) begin
                write <= 0;

            end else begin
                write <= 1'b0;
                user <= 3'd0;
                ALUSrc <= 2'd0;
                global1 <= 5'd0;
                displaymode <= 2'd0;
            end   
        end
    end

endmodule*/
module ControlUnit (
    input logic clock,
    input logic reset,

    input logic switchmode,
    input logic timezone,
    input logic up,
    input logic down,
    input logic settime,

    input logic timereset,
    input logic stop,

    output logic write,
    output logic [3:0] user,
    output logic [1:0] ALUSrc,
    output logic [4:0] global1,
    output logic [1:0] displaymode,
    output logic timereset2
);

    logic switchmode_detected;
    logic timezone_detected;
    logic up_detected;
    logic down_detected;
    logic settime_detected;
    logic timereset_detected;
    logic stop_detected;

    logic [1:0] mode;

    // 00：正常运行；01：编辑秒；10：编辑分；11：编辑小时
    logic [1:0] edit_field;
    logic paused;

    risingedge_detector switchmode_press (
        .in(switchmode), .detected(switchmode_detected),
        .clock(clock), .reset(reset)
    );

    risingedge_detector timezone_press (
        .in(timezone), .detected(timezone_detected),
        .clock(clock), .reset(reset)
    );

    risingedge_detector up_press (
        .in(up), .detected(up_detected),
        .clock(clock), .reset(reset)
    );

    risingedge_detector down_press (
        .in(down), .detected(down_detected),
        .clock(clock), .reset(reset)
    );

    risingedge_detector settime_press (
        .in(settime), .detected(settime_detected),
        .clock(clock), .reset(reset)
    );

    risingedge_detector timereset_press (
        .in(timereset), .detected(timereset_detected),
        .clock(clock), .reset(reset)
    );

    risingedge_detector stop_press (
        .in(stop), .detected(stop_detected),
        .clock(clock), .reset(reset)
    );

    assign displaymode = mode;

    // 保存模式、时区、编辑字段和暂停状态
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            mode       <= 2'b00;
            global1     <= 5'd0;
            edit_field <= 2'b00;
            paused     <= 1'b0;
        end else begin
            if (switchmode_detected) begin
                mode       <= mode + 2'd1;
                edit_field <= 2'b00;
            end else if (timezone_detected) begin
                // 偏移 0..23；24 与 0 重复
                global1 <= (global1 == 5'd23)
                          ? 5'd0 : global1 + 5'd1;
            end else if (settime_detected) begin
                edit_field <= edit_field + 2'd1;
            end else if (stop_detected &&
                         mode != 2'b00 &&
                         mode != 2'b11) begin
                paused <= ~paused;
            end
        end
    end

    // 根据当前状态和按键事件生成控制信号
    always_comb begin
        user       = 4'b0000;
        timereset2 = 1'b0;

        // 暂按 10 为倒计时，其余模式为递增。
        ALUSrc = (mode == 2'b10) ? 2'b01 : 2'b00;

        // 编辑期间暂停正常更新。
        write = !reset && !paused && (edit_field == 2'b00);

        if (!reset) begin
            if (timereset_detected &&
                mode != 2'b00 &&
                mode != 2'b11) begin

                timereset2 = 1'b1;
                write = 1'b0;

            end else if (edit_field != 2'b00) begin
                ALUSrc = 2'b10;

                case (edit_field)
                    2'b01: user[3:1] = 3'b001; // 秒
                    2'b10: user[3:1] = 3'b010; // 分
                    2'b11: user[3:1] = 3'b100; // 小时
                    default: user[3:1] = 3'b000;
                endcase

                // ALU：0 加一，1 减一。
                user[0] = down_detected;

                // 只有单独按 up 或 down，才执行一次编辑。
                write = up_detected ^ down_detected;
            end
        end
    end

endmodule