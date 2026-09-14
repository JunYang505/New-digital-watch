module storage(
    input logic reset,
    input logic clk,
    input logic write,

    input logic [5:0]newseconds,
    input logic [5:0]newminutes,
    input logic [4:0]newhours,
    
    output logic [5:0]seconds,
    output logic [5:0]minutes,
    output logic [4:0]hours
);

always_ff @( posedge clk ) begin : 
    if (reset) begin
        seconds <= 0;
        minutes <= 0;
        hours <= 0;
    end

    else if (write) begin
        seconds <= newseconds;
        minutes <= newminutes;
        hours <= newhours;
    end

end

endmodule