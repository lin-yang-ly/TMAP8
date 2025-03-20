import os
import subprocess
from pathlib import Path

# Original input file
current_dir = Path().absolute()

################################################################################
################## Run experiment AEH model without smoothing ##################
################################################################################
# input_file = current_dir / '../AEH_experiments_image.i'

# # List of cases to run
# cases = [
#     {
#         'png_file': f'experiment_grayscale_figures/experiment_mario_microstructure_Fe_{j}_phases_{i:03}.png',
#         'output_name': f'AEH_experiment_mario_microstructure_Fe_{j}_slide_{i:03}'
#     }
#     for j in ["010", "025", "050"]
#     for i in range(202)
# ]


# # Process each case
# for index, case in enumerate(cases):
#     try:
#         print(f"\nProcessing case with {case['png_file']}...")
#         # Run MOOSE with the modified input file
#         subprocess.run(['../../../../tmap8-opt', '-i', str(input_file),
#                         f'figure_file_name="{case["png_file"]}"',
#                         f'output_file_name="{case["output_name"]}"'], check=True)
#         print(f"Successfully completed run for {case['output_name']}")

#     except subprocess.CalledProcessError as e:
#         print(f"Error running case {case['output_name']}: {e}")

################################################################################
################## Run artificial AEH model without smoothing ##################
################################################################################
input_file = current_dir / 'step2_split_diffusivity_phases.i'

# List of cases to run
cases = [
    {
        'Fe_fraction': f'{j}',
        'input_name': f'gold/Polycrystal_Domain_2000_NumGrainHor_{i}_NumGrainVert_{i}_'+'PF${Fe_fraction}.e',
        'output_name': f'AEH_Diffusion_Tritium_D_2000_H_{i}_V_{i}_'+'PF${Fe_fraction}_0step_output'
    }
    for i in [4, 7, 10, 12]
    for j in ["005", "015", "025", "035", "045", "055", "065", "075", "085", "095"]
]

# Process each case
for index, case in enumerate(cases):
    try:
        print(f"\nProcessing case with {case['input_name']}...")
        # Run MOOSE with the modified input file
        subprocess.run(['../../../tmap8-opt', '-i', str(input_file),
                        f'Fe_fraction="{case["Fe_fraction"]}"',
                        f'file_name="{case["input_name"]}"',
                        f'output_file_name="{case["output_name"]}"'], check=True)
        print(f"Successfully completed run for {case['output_name']}")

    except subprocess.CalledProcessError as e:
        print(f"Error running case {case['output_name']}: {e}")
