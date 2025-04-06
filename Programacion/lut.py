import math

import numpy as np

# Parameters for the sine LUT
num_entries = 4096*2   # Number of entries in the LUT
max_value = 127     # Maximum value for the LUT (7-bit range)
output_file = "./src/PRAM/sine_wave.v"

# Create a function to generate the sine LUT in Verilog format
def generate_sine_lut():
    lut_values = []
    for i in range(num_entries):
        # Calculate the sine value, scaling it to fit the desired range
        sine_value = math.sin(2 * math.pi * i / num_entries)
        scaled_value = np.int8(np.round((sine_value + 1) * (max_value / 2), 0))  # Scale sine values to fit range [0, max_value]
        lut_values.append(scaled_value)

    # Generate Verilog initial block code
    with open(output_file, 'w', ) as f:
        f.write(f"  reg [6:0] lut [0:{num_entries-1}];\n")  # 7-bit LUT
        f.write(f"  initial begin\n")
        for i, value in enumerate(lut_values):
            f.write(f"    lut[{i}] = {value};\n")
        f.write(f"  end\n")
    
    print(f"Sine LUT Verilog code written to {output_file}")

# Generate the sine LUT Verilog file
generate_sine_lut()
