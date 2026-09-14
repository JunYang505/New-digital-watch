module ALU (
    input logic [1:0]ALUSrc,
    input logic [3:0]user, // hour,minute,second,down(1)up(0)

    input logic [5:0]seconds,
    input logic [5:0]minutes,
    input logic [4:0]hours,

    input logic [5:0]alarmseconds,
    input logic [5:0]alarmminutes,
    input logic [4:0]alarmhours,

    output logic [5:0]newseconds,
    output logic [5:0]newminutes,
    output logic [4:0]newhours,
    output logic zero,
    output logic zero2

);

    always @(*) begin 
        newseconds = 0;
        newminutes = 0;
        newhours = 0;

        if (ALUSrc == 2'b00) begin//+ 
            
                if (seconds == 6'd59) begin
                    
                    newseconds = 0; 
                    if (minutes == 6'd59) begin
                        
                        newminutes = 0; 
                        if (hours == 5'd23) begin
                            newhours = 0; 
                        end else begin
                            newhours = hours + 1; end

                    end else begin
                        newminutes = minutes + 1;
                        newhours = hours; end
                end else begin
                    newseconds = seconds + 1;
                    newminutes = minutes;
                    newhours = hours; end
        end


        else if (ALUSrc == 2'b01) begin//-
            if (seconds == 0) begin
                if (minutes == 0) begin
                    if (hours == 0) begin
                        newseconds = 0;
                        newminutes = 0;
                        newhours = 0;
                        zero = 1;
                    end else begin
                        newhours = hours - 1;
                        newminutes = 6'd59;
                        newseconds = 6'd59;
                    end
                end else begin
                    newhours = hours;
                    newminutes = minutes - 1;
                    newseconds = 6'd59;

                end
            

            end else begin
                newseconds = seconds - 1;
                newminutes = minutes;
                newhours = hours; end


        end else if (ALUSrc == 2'b10) begin
            if (~user[0]) begin //up
                case (user[3:1])
                    3'b001: newseconds = (seconds == 59) ? 0 : seconds + 1;
                    3'b010: newminutes = (minutes == 59) ? 0 : minutes + 1;
                    3'b100: newhours = (hours == 23) ? 0 : hours + 1;
                    default: ;
                endcase
            end else if (user[0]) begin //down
                case (user[3:1])
                    3'b001: newseconds = (seconds == 0) ? 59 : seconds - 1;
                    3'b010: newminutes = (minutes == 0) ? 59 : minutes - 1;
                    3'b100: newhours = (hours == 0) ? 23 : hours - 1;
                    default: ;
                endcase
            end else begin
                newseconds = seconds;
                newminutes = minutes;
                newhours = hours;
                end     

        end else if (ALUSrc == 2'b11 )begin
            zero2 = ~(|(seconds - alarmseconds)) | (|(minutes - alarmminutes)) | (|(hours - alarmhours));
        
        
        
        end else begin
            newseconds = seconds;
            newminutes = minutes;
            newhours = hours;
        end

    end

endmodule