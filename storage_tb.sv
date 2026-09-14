module storage_tb ();

    logic reset;
    logic clk;
    logic write;
    logic [6:0]newseconds;
    logic [6:0]newminutes;
    logic [5:0]newhours;
    logic [6:0]seconds;
    logic [6:0]minutes;
    logic [5:0]hours;

    integer  errors;

    storage dut(
        .reset(reset),
        .clk(clk),
        .write(write),
        .newseconds(newseconds),
        .newminutes(newminutes),
        .newhours(newhours),
        .seconds(seconds),
        .minutes(minutes),
        .hours(hours)
    );

    initial begin


    end


endmodule