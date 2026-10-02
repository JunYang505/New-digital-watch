module extend (
    input logic [5:0]hours,
    input logic [5:0]global1,

    output logic [5:0]globaltime

);
 
    assign globaltime = hours + global1;

endmodule