// look in pins.pcf for all the pin names on the TinyFPGA BX board
module top (
    input CLK,    // 16MHz clock
    output LED,   // User/boot LED next to power LED
    output USBPU,  // USB pull-up resistor

    output PIN_14,
    output PIN_7,

    input PIN_8,
    input PIN_9,
    input PIN_10,
    input PIN_11,
    input PIN_12,
    input PIN_13,
    input PIN_24,
    input PIN_23,
    input PIN_22,
    input PIN_21,
    input PIN_20,
    input PIN_19,
    input PIN_18,
    input PIN_17,
    input PIN_16,
    input PIN_15,


    //internal wires go into the 4 adders

);
    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    ////////
    // make a simple blink circuit
    ////////

    // keep track of time and location in blink_pattern
    reg [25:0] blink_counter;

    // pattern that will be flashed over the LED over time
    wire [31:0] blink_pattern = 32'b101111100000111110000011111;

    // increment the blink_counter every clock
    reg[27:0] counter=28'd0;
    parameter DIVISOR = 28'd256;
    parameter freq1_divisor = 28'd256;
    wire clock_out;
    wire freq_out1;

    always @(posedge CLK) begin
        blink_counter <= blink_counter + 1;

        // The frequency of the output clk_out
        //  = The frequency of the input clk_in divided by DIVISOR
        // For example: Fclk_in = 50Mhz, if you want to get 1Hz signal to blink LEDs
        // You will modify the DIVISOR parameter value to 28'd50.000.000
        // Then the frequency of the output clk_out = 50Mhz/50.000.000 = 1Hz

         counter <= counter + 28'd1;
         if(counter>=(DIVISOR-1))
          counter <= 28'd0;
      end

      assign clock_out = (counter<DIVISOR/2)?1'b0:1'b1;

      wire [27:0] freq_counter1 = 0;

      wire [7:0] pwm_pattern = 50;  //starting value of true square wave


      reg [7:0] pwm_counter = 0;    //counting the steps

      wire pwm_pitch = 440;

      always @(posedge clock_out) begin
          freq_counter1 <= freq_counter1 + 1;

           if(freq_counter1 >= (freq1_divisor-1))
            freq_counter1 <= 28'd0;

            if (freq_counter1 == 0)
              phase <= phase + freq_step;

            if ( pwm_counter < 128 ) pwm_counter <= pwm_counter + 1; //100
            else pwm_counter <= 0;

            //pwm_pattern <= sinetable[phase[31:24]];
        end

      assign freq_out1 = ( freq_counter1 < freq1_divisor/2 )?1'b0:1'b1;
      assign next = 8'b0;

      always @(posedge freq_out1) begin
      //pwm method
        pwm_pattern <= pwmsinetable[next];
      end

      always @ (posedge freq_out1) begin
      next <= next + 1;
      if (next >= 255) next = 0;

      end

      // light up the LED according to the pattern
      assign LED = blink_pattern[blink_counter[25:21]];

      assign sinewave = pwm_pattern;

//freq_step = 2^N * frequency_hz / sample_clock_rate_hz
// = 2^32 * 440 / 16000000
// =
//used to be 118111 as freq step
    reg [31:0] freq_step = 1; //adjustable in final code
    reg [31:0] phase;
    reg [7:0] sinetable[0:255];
    initial $readmemh("wootsinetable.hex", sinetable);
    assign PIN_14 = sinewave;




endmodule
