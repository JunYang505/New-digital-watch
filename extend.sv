module extend (
    input logic [5:0]hours,
    input logic [5:0]global,

    output logic [5:0]globaltime

);
 
    assign globaltime = hours + global;

endmodule