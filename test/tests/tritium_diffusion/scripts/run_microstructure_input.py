import os
import subprocess
from pathlib import Path

# Original input file
current_dir = Path().absolute()
input_file_large_grain = current_dir / 'step1_grain_growth.i'
input_file_small_grain = current_dir / 'step1_grain_growth_ops.i'

# List of cases to run
cases = [
    {
        'input_name': f'EBSD_files/Polycrystal_Domain_2000_NumGrainHor_{i}_NumGrainVert_{i}_PF{j}.txt',
        'output_name': f'Polycrystal_Domain_2000_NumGrainHor_{i}_NumGrainVert_{i}_PF{j}',
        'grain_edge_num': i
    }
    for i in [4, 7, 10, 12]
    for j in ["005", "015", "025", "035", "045", "055", "065", "075", "085", "095"]
]


# Process each case
for index, case in enumerate(cases):
    try:
        print(f"\nProcessing case with {case['input_name']}...")
        # Run MOOSE with the modified input file
        if case['grain_edge_num'] == 12: input_file = input_file_small_grain
        else: input_file = input_file_large_grain
        subprocess.run(['mpiexec', '-n', '6', '../../../tmap8-opt', '-i', str(input_file),
                        f'input_file_name="{case["input_name"]}"',
                        f'output_file_name="{case["output_name"]}"'], check=True)
        print(f"Successfully completed run for {case['output_name']}")

    except subprocess.CalledProcessError as e:
        print(f"Error running case {case['output_name']}: {e}")
