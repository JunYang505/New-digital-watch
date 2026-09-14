module  display(

    input logic [6:0]second,
    input logic [6:0]minute,
    input logic [5:0]hour,


    output logic [7:0] display0,
    output logic [7:0] display1,
    output logic [7:0] display2,
    output logic [7:0] display3,
    output logic [7:0] display4,
    output logic [7:0] display5,
    output logic [7:0] display6,
    output logic [7:0] display7
);

logic [3:0] oneplace_second;
logic [3:0] tenplace_second;
logic [3:0] oneplace_minute;
logic [3:0] tenplace_minute;
logic [3:0] oneplace_hour;
logic [3:0] tenplace_hour;

always_comb begin

    oneplace_second = 4'(second % 10);
    tenplace_second = 4'(second / 10);
    oneplace_minute = 4'(minute % 10);
    tenplace_minute = 4'(minute / 10);
    oneplace_hour = 4'(hour % 10);
    tenplace_hour = 4'(hour / 10);

end

    // hour display

    seven_segments_hex s5(
    .digit(display5),
    .hex(tenplace_hour)
);  //display5

    seven_segments_hex s4(
    .digit(display4),
    .hex(oneplace_hour)
);//display4

    // minute display

    seven_segments_hex s3(
    .digit(display3),
    .hex(tenplace_minute)
);//display3

    seven_segments_hex s2(
    .digit(display2),
    .hex(oneplace_minute)
);//display2

    // second display

    seven_segments_hex s1(
    .digit(display1),
    .hex(tenplace_second)
);//display1

    seven_segments_hex s0(
    .digit(display0),
    .hex(oneplace_second)
);//display0

endmodule