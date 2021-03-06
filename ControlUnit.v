/************************************************************/
/* Module Name: ControlUnit                                 */
/* Module Function:                                         */
/*  Control unit is responsible of producing the required   */
/*  signals for the Datapath and Data memory based on the   */
/*  instruction coming from the instruction memory whose    */    
/*  most significant 5-bits go to the control unit main     */
/*  decoder and least significant 5-bits go to the ALU      */
/*  decoder.                                                */
/************************************************************/
module ControlUnit #
(
    parameter   INSTR_WIDTH =   32
)
(
    input   wire    [INSTR_WIDTH-1:0]   Instruction ,
    input   wire                        Zero        ,

    output  reg                         Jmp         ,
    output  reg                         MemtoReg    ,
    output  reg                         MemWrite    ,
    output  reg                         ALUSrc      ,
    output  reg                         RegDst      ,
    output  reg                         RegWrite    ,
    output  reg     [2:0]               ALUControl  ,
    output  wire                        PCSrc
);

    reg         Branch  ;

    localparam  rType           =   6'b00_0000    ;
    localparam  loadWord        =   6'b10_0011    ;
    localparam  storeWord       =   6'b10_1011    ;
    localparam  addImmediate    =   6'b00_1000    ;
    localparam  branchIfEqual   =   6'b00_0100    ;
    localparam  jump_inst       =   6'b00_0010    ;

    localparam  AND =   6'b10_0100  ;
    localparam  OR  =   6'b10_0101  ;
    localparam  ADD =   6'b10_0000  ;
    localparam  SUB =   6'b10_0010  ;
    localparam  SLT =   6'b10_1010  ;
    localparam  MUL =   6'b01_1100  ;

    reg     [1:0]   ALUOp   ;

    wire    [5:0]   OpCode  ;
    wire    [5:0]   Funct   ;

    assign  OpCode  =   Instruction [31 : 26]   ;
    assign  Funct   =   Instruction [5 : 0]     ;
    assign  PCSrc   =   Branch  &   Zero        ;

    always @(*) 
        begin
            case (OpCode)
                rType :
                    begin
                        Jmp         =   1'b0    ; 
                        ALUOp       =   2'b10   ;
                        MemWrite    =   1'b0    ;
                        RegWrite    =   1'b1    ;
                        RegDst      =   1'b1    ;
                        ALUSrc      =   1'b0    ;
                        MemtoReg    =   1'b0    ;
                        Branch      =   1'b0    ;
                    end
                loadWord :
                    begin
                        Jmp         =   1'b0    ; 
                        ALUOp       =   2'b00   ;
                        MemWrite    =   1'b0    ;
                        RegWrite    =   1'b1    ;
                        RegDst      =   1'b0    ;
                        ALUSrc      =   1'b1    ;
                        MemtoReg    =   1'b1    ;
                        Branch      =   1'b0    ;
                    end
                storeWord :
                    begin
                        Jmp         =   1'b0    ; 
                        ALUOp       =   2'b00   ;
                        MemWrite    =   1'b1    ;
                        RegWrite    =   1'b0    ;
                        RegDst      =   1'b0    ;
                        ALUSrc      =   1'b1    ;
                        MemtoReg    =   1'b1    ;
                        Branch      =   1'b0    ;
                    end
                addImmediate :
                    begin
                        Jmp         =   1'b0    ; 
                        ALUOp       =   2'b00   ;
                        MemWrite    =   1'b0    ;
                        RegWrite    =   1'b1    ;
                        RegDst      =   1'b0    ;
                        ALUSrc      =   1'b1    ;
                        MemtoReg    =   1'b0    ;
                        Branch      =   1'b0    ;
                    end
                branchIfEqual :
                    begin
                        Jmp         =   1'b0    ; 
                        ALUOp       =   2'b01   ;
                        MemWrite    =   1'b0    ;
                        RegWrite    =   1'b0    ;
                        RegDst      =   1'b0    ;
                        ALUSrc      =   1'b0    ;
                        MemtoReg    =   1'b0    ;
                        Branch      =   1'b1    ;
                    end
                jump_inst :
                    begin
                        Jmp         =   1'b1    ; 
                        ALUOp       =   2'b00   ;
                        MemWrite    =   1'b0    ;
                        RegWrite    =   1'b0    ;
                        RegDst      =   1'b0    ;
                        ALUSrc      =   1'b0    ;
                        MemtoReg    =   1'b0    ;
                        Branch      =   1'b0    ;
                    end
                default : 
                    begin
                        Jmp         =   1'b0    ; 
                        ALUOp       =   2'b00   ;
                        MemWrite    =   1'b0    ;
                        RegWrite    =   1'b0    ;
                        RegDst      =   1'b0    ;
                        ALUSrc      =   1'b0    ;
                        MemtoReg    =   1'b0    ;
                        Branch      =   1'b0    ;
                    end  
            endcase
        end
    
    always @(*) 
        begin
           case (ALUOp)
               2'b00    :   ALUControl  =   3'b010  ;
               2'b01    :   ALUControl  =   3'b100  ; 
               2'b10    :   
                    begin
                        case (Funct)
                            AND :   ALUControl  =   3'b000  ;
                            OR  :   ALUControl  =   3'b001  ;
                            ADD :   ALUControl  =   3'b010  ;
                            SUB :   ALUControl  =   3'b100  ;
                            SLT :   ALUControl  =   3'b110  ;
                            MUL :   ALUControl  =   3'b101  ;
                            default: ALUControl =   3'b000  ;
                        endcase
                    end
               default  :   ALUControl  =   3'b010  ;
           endcase  
        end
endmodule