module ControlUnit (
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
    output logic [2:0]user,
    output logic [1:0]ALUSrc,
    output logic [4:0]global,
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
            global <= 5'd0;
            displaymode <= 2'd0;
        
        end else begin

            if (switchmode) begin
                if (mode == 2'b00) begin     
                    mode <= 2'b11;
                end else begin
                    mode <= mode + 1;
                end

            end else if (timezone) begin
                    if (global == 5'd24 ) begin
                        global <= 5'd0;
                    end else begin
                        global <= global + 1;
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
                global <= 5'd0;
                displaymode <= 2'd0;
            end   
        end
    end

endmodule