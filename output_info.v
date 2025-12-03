module output_info#(
    parameter MAX_ITEMS           = 1024,
    parameter MAX_CURRENCY        = 100,
    parameter MAX_AVAIL_ITEMS     = 255,
    parameter MAX_COST            = 25500,

    parameter currency_width      = 8,     // can store item price up to 255
    parameter items_addr          = 10,    // item ID
    parameter no_items_addr       = 8,     // up to 255 items
    parameter total_amount_width  = 16     // can hold money sum up to 65535
)(
    input  wire                            clk,
    input  wire                            rstn,
    input  wire                            dispense_enable,
    input  wire [items_addr-1        : 0]  item_selected,
    input  wire [no_items_addr-1     : 0]  no_items_selected,
    input  wire [no_items_addr-1     : 0]  avail_items,
    input  wire [currency_width-1    : 0]  item_price,
    input  wire [total_amount_width-1: 0]  total_amount,
    //input  wire [ total_amount_width-1: 0 ] invalid_amount
    output reg                             item_dispense_valid,
    output reg  [items_addr-1         : 0] item_dispensed,
    output reg  [total_amount_width-1 : 0] change_dispensed,
    output reg  [no_items_addr-1      : 0] no_items_dispensed
);
    // ZERO-EXTENSION BEFORE MULTIPLY 
    wire [total_amount_width-1:0] item_price_ext = {{(total_amount_width - currency_width){1'b0}}, item_price};
    wire [total_amount_width-1:0] no_items_ext   = {{(total_amount_width - no_items_addr){1'b0}}, no_items_selected};

    // Multiply in a width-safe way
    wire [total_amount_width-1:0] items_price = item_price_ext * no_items_ext;
    initial begin
         item_dispense_valid <= 1'b0;
         item_dispensed      <= 0;
         change_dispensed    <= 0;
         no_items_dispensed  <= 0;
    end

    // MAIN LOGIC
    always @(posedge clk or negedge rstn) begin
        item_dispense_valid <= 1'b0;
        item_dispensed      <= 0;
        change_dispensed    <= 0;
        no_items_dispensed  <= 0;
        if (!rstn) begin
            item_dispense_valid <= 1'b0;
            item_dispensed      <= 0;
            change_dispensed    <= 0;
            no_items_dispensed  <= 0;
        end
        else begin
            if (dispense_enable) begin
                if ((avail_items >= no_items_selected) && (total_amount >= items_price)) begin
                    item_dispense_valid <= 1'b1;
                    item_dispensed      <= item_selected;
                    no_items_dispensed  <= no_items_selected;
                    change_dispensed    <= total_amount - items_price;
                end
                else begin
                    item_dispense_valid <= 1'b0;
                    item_dispensed      <= 0;
                    no_items_dispensed  <= 0;
                    change_dispensed    <= total_amount;
                end
            end
        end
    end
endmodule