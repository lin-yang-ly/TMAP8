import os
import subprocess
from pathlib import Path
from joblib import Parallel, delayed

# Original input file
current_dir = Path().absolute()

################################################################################
################## Run experiment AEH model without smoothing ##################
################################################################################
input_file = current_dir / '../AEH_experiments_image.i'

# List of cases to run Polycrystal_Domain_2048_NumGrainHor_4_NumGrainVert_4_PF015_phase_structure
phase_fraction = ["005", "015", "025", "035", "045", "055", "065", "075", "085", "095"]
grain_size = ["20", "50", "100", "200", "500", "1000"]
cases = [
    {
        'png_file': f'simulation_IC_files/Polycrystal_Domain_2048_NumGrainHor_{j}_NumGrainVert_{j}_PF{i}_phase_structure.png',
        'output_name': f'AEH_simulation_microstructure_Fe_{i}_grain_{j:04}'
    }
    for j in grain_size
    for i in phase_fraction
]


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

# Process each case in parallel using joblib
def process_case(index, case):
    try:
        print(f"\nProcessing case with {case['png_file']}...")
        # Run MOOSE with the modified input file
        subprocess.run(['../../../../tmap8-opt', '-i', str(input_file),
                        f'figure_file_name="{case["png_file"]}"',
                        f'output_file_name="{case["output_name"]}"'], check=True)
        print(f"Successfully completed run for {case['output_name']}")
    except subprocess.CalledProcessError as e:
        print(f"Error running case {case['output_name']}: {e}")

Parallel(n_jobs=-1)(delayed(process_case)(index, case) for index, case in enumerate(cases))


################################################################################
################## Run artificial AEH model without smoothing ##################
################################################################################
# input_file = current_dir / 'step2_split_diffusivity_phases.i'

# # List of cases to run
# cases = [
#     {
#         'Fe_fraction': f'{j}',
#         'input_name': f'gold/Polycrystal_Domain_2000_NumGrainHor_{i}_NumGrainVert_{i}_'+'PF${Fe_fraction}.e',
#         'output_name': f'AEH_Diffusion_Tritium_D_2000_H_{i}_V_{i}_'+'PF${Fe_fraction}_0step_output'
#     }
#     for i in [4, 7, 10, 12]
#     for j in ["005", "015", "025", "035", "045", "055", "065", "075", "085", "095"]
# ]

# # Process each case
# for index, case in enumerate(cases):
#     try:
#         print(f"\nProcessing case with {case['input_name']}...")
#         # Run MOOSE with the modified input file
#         subprocess.run(['../../../tmap8-opt', '-i', str(input_file),
#                         f'Fe_fraction="{case["Fe_fraction"]}"',
#                         f'file_name="{case["input_name"]}"',
#                         f'output_file_name="{case["output_name"]}"'], check=True)
#         print(f"Successfully completed run for {case['output_name']}")

#     except subprocess.CalledProcessError as e:
#         print(f"Error running case {case['output_name']}: {e}")
