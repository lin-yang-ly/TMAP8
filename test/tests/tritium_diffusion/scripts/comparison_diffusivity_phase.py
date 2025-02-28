import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

#===============================================================================
# Constants and history (see input file val-2b.i)

temperature = 1000 # K

#===============================================================================
# Define methods

def numerical_solution_on_experiment_input(experiment_input, tmap_input, tmap_output):
    """interpolate numerical solution to the experimental time step

    Args:
        experiment_input (float, ndarray): experimental input data points
        tmap_input (float, ndarray): numerical input data points
        tmap_output (float, ndarray): numerical output data points

    Returns:
        float, ndarray: updated tmap_output based on the data points in experiment_input
    """
    new_tmap_output = np.zeros(len(experiment_input))
    for i in range(len(experiment_input)):
        left_limit = np.argwhere((np.diff(tmap_input < experiment_input[i])))[0][0]
        right_limit = left_limit + 1
        new_tmap_output[i] = (experiment_input[i] - tmap_input[left_limit]) / (tmap_input[right_limit] - tmap_input[left_limit]) * (tmap_output[right_limit] - tmap_output[left_limit]) + tmap_output[left_limit]
    return new_tmap_output

def read_csv_from_TMAP8(file_name, parameter_names):
    """Read simulation data in csv files from TMAP8

    Args:
        file_name (string): the file name at simulation folder
        parameter_names (list): the list of parameters extracted from csv files

    Returns:
        float, ndarray: the matrix keep the simulation results, first axis depended on len(parameter_names)
    """
    if "/TMAP8/doc/" in script_folder:     # if in documentation folder
        csv_folder = f"../../../../test/tests/Li2O-Fe_diffusion/gold/{file_name}"
    else:                                  # if in test folder
        csv_folder = f"../gold/{file_name}"
    simulation_data = pd.read_csv(csv_folder)
    simulation_results = []
    for i in range(len(parameter_names)):
        simulation_results.append(simulation_data[parameter_names[i]])
    simulation_results = np.array(simulation_results)
    return simulation_results

################################################################################
########################## 2D multi-phases multi-sizes #########################
################################################################################

parameter_names = ['D_x_AEH','D_y_AEH','Fe_phase_fraction','diffusivity_Fe_theory','diffusivity_Li2O_theory','effective_solubility','solubility_Fe_theory','solubility_Li2O_theory'] # s, atoms/nm^3, atom
# D - nm^2/s, S - at/nm^3/Pa

# ============================================================================ #
# Extract effective diffusivity in AEH model

Fe_fraction_array = np.array(["0.05", "0.15", "0.25", "0.35", "0.45", "0.55", "0.65", "0.75", "0.85", "0.95"])
file_name_list_M1 = [f'../AEH_Diffusion_Tritium_D_2000_H_10_V_10_PF0{i_Fe_fraction[2:]}_output.csv' for i_Fe_fraction in Fe_fraction_array]

M1_simulation_results_list = []
effective_diffusivity = np.zeros(len(file_name_list_M1))
real_Fe_fraction = np.zeros(len(file_name_list_M1))
for i in range(len(file_name_list_M1)):
    # M1 results
    file_name_M1 = file_name_list_M1[i]
    M1_simulation_results = read_csv_from_TMAP8(file_name_M1, parameter_names) # read csv file
    effective_diffusivity[i] = M1_simulation_results[parameter_names.index('D_x_AEH')][-1]
    real_Fe_fraction[i] = M1_simulation_results[parameter_names.index('Fe_phase_fraction')][-1]
    M1_simulation_results_list.append(M1_simulation_results)
# print(real_Fe_fraction)

# ============================================================================ #
# Plot effective diffusivity

diffusivity_Fe_theory = M1_simulation_results_list[0][parameter_names.index('diffusivity_Fe_theory')][-1]
diffusivity_Li2O_theory = M1_simulation_results_list[0][parameter_names.index('diffusivity_Li2O_theory')][-1]
real_Fe_fraction = np.insert(real_Fe_fraction, [0,10],[0,1])
# print(real_Fe_fraction)
effective_diffusivity = np.insert(effective_diffusivity, [0,10],[diffusivity_Li2O_theory,diffusivity_Fe_theory])

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(real_Fe_fraction, effective_diffusivity, label=u"D$_{eff}$ - 100 grains", c=f"C0")
ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Fe_theory], '--', label=u"theory", c=f"C0")
ax.plot([0,1], [diffusivity_Fe_theory,diffusivity_Fe_theory], '--',c='gray')
ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Li2O_theory], '--',c='gray')
ax.set_xlabel(u'Fe phase fraction (-)')
ax.set_ylabel(u"Effective diffusivity (m$^2$/s)")
ax.legend(loc="best")
# ax.set_ylim(bottom=0)
plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../figures/multi_phases_effective_diffusivity_comparison_x_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)
