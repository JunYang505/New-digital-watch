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

endmodule