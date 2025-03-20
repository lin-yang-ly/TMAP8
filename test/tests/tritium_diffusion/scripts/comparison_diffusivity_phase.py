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
file_name_list_M1 = []
for i_micro in ["4", "7", "10", "12"]:
    file_name_list_M1.append([f'../AEH_files/AEH_Diffusion_Tritium_D_2000_H_{i_micro}_V_{i_micro}_PF0{i_Fe_fraction[2:]}_output.csv' for i_Fe_fraction in Fe_fraction_array])
num_micros = len(file_name_list_M1)
num_fraction = len(Fe_fraction_array)
print(f"{num_micros} x {num_fraction}")

M1_simulation_results_list = []
effective_diffusivity = np.zeros((num_micros, num_fraction))
real_Fe_fraction = np.zeros((num_micros, num_fraction))
for i in range(len(file_name_list_M1)):
    tmp_M1_simulation_results_list = []
    for j in range(len(file_name_list_M1[i])):
        # M1 results
        file_name_M1 = file_name_list_M1[i][j]
        M1_simulation_results = read_csv_from_TMAP8(file_name_M1, parameter_names) # read csv file
        effective_diffusivity[i,j] = M1_simulation_results[parameter_names.index('D_x_AEH')][-1]
        real_Fe_fraction[i,j] = M1_simulation_results[parameter_names.index('Fe_phase_fraction')][-1]
        tmp_M1_simulation_results_list.append(M1_simulation_results)

    M1_simulation_results_list.append(tmp_M1_simulation_results_list)
# print(real_Fe_fraction)

# ============================================================================ #
# Plot effective diffusivity

diffusivity_Fe_theory = M1_simulation_results_list[0][0][parameter_names.index('diffusivity_Fe_theory')][-1]
diffusivity_Li2O_theory = M1_simulation_results_list[0][0][parameter_names.index('diffusivity_Li2O_theory')][-1]
real_Fe_fraction_with_boundary = np.hstack([np.zeros((num_micros, 1)), real_Fe_fraction, np.ones((num_micros, 1))]) # np.insert(real_Fe_fraction, [0,10],[0,1])
# print(real_Fe_fraction)
effective_diffusivity_with_boundary = np.hstack([np.ones((num_micros, 1))*diffusivity_Li2O_theory, effective_diffusivity, np.ones((num_micros, 1))*diffusivity_Fe_theory]) # np.insert(effective_diffusivity, [0,10],[diffusivity_Li2O_theory,diffusivity_Fe_theory])

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

label_list = ["16 grains", "49 grains", "100 grains", "144 grains"]
color_list = [1,2,0,3]
for i in range(num_micros):
    ax.plot(real_Fe_fraction_with_boundary[i], effective_diffusivity_with_boundary[i], '.', label=r"D$_{eff}$ - " + f"{label_list[i]}", c=f"C{color_list[i]}")
# ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Fe_theory], '--', label=u"theory", c=f"C0")
ax.plot([0,1], [diffusivity_Fe_theory,diffusivity_Fe_theory], '--',c='gray')
ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Li2O_theory], '--',c='gray')
ax.text(0.35, 1.6e7, u'diffusivity of Li$_2$O',fontweight='bold',c=f"k")
ax.text(0.35, 9.5e8, u'diffusivity of Fe',fontweight='bold',c=f"k")
ax.set_xlabel(u'Fe phase fraction (-)')
ax.set_ylabel(u"Effective diffusivity (m$^2$/s)")
ax.legend(loc="best")
# ax.set_ylim(bottom=0)
plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../figures/multi_phases_effective_diffusivity_comparison_x_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)


# ============================================================================ #
# Extract effective diffusivity in AEH model without smoothing

Fe_fraction_array = np.array(["0.05", "0.15", "0.25", "0.35", "0.45", "0.55", "0.65", "0.75", "0.85", "0.95"])
file_name_list_M2 = []
for i_micro in ["4", "7", "10", "12"]:
    file_name_list_M2.append([f'../AEH_files/AEH_Diffusion_Tritium_D_2000_H_{i_micro}_V_{i_micro}_PF0{i_Fe_fraction[2:]}_0step_output.csv' for i_Fe_fraction in Fe_fraction_array])
num_micros = len(file_name_list_M2)
num_fraction = len(Fe_fraction_array)
print(f"{num_micros} x {num_fraction}")

M2_simulation_results_list = []
effective_diffusivity_M2 = np.zeros((num_micros, num_fraction))
real_Fe_fraction_M2 = np.zeros((num_micros, num_fraction))
for i in range(len(file_name_list_M2)):
    tmp_M2_simulation_results_list = []
    for j in range(len(file_name_list_M2[i])):
        # M2 results
        file_name_M2 = file_name_list_M2[i][j]
        M2_simulation_results = read_csv_from_TMAP8(file_name_M2, parameter_names) # read csv file
        effective_diffusivity_M2[i,j] = M2_simulation_results[parameter_names.index('D_x_AEH')][-1]
        real_Fe_fraction_M2[i,j] = M2_simulation_results[parameter_names.index('Fe_phase_fraction')][-1]
        tmp_M2_simulation_results_list.append(M2_simulation_results)

    M2_simulation_results_list.append(tmp_M2_simulation_results_list)
# print(real_Fe_fraction)

# ============================================================================ #
# Plot effective diffusivity
real_Fe_fraction_M2_with_boundary = np.hstack([np.zeros((num_micros, 1)), real_Fe_fraction_M2, np.ones((num_micros, 1))]) # np.insert(real_Fe_fraction, [0,10],[0,1])
# print(real_Fe_fraction)
effective_diffusivity_M2_with_boundary = np.hstack([np.ones((num_micros, 1))*diffusivity_Li2O_theory, effective_diffusivity_M2, np.ones((num_micros, 1))*diffusivity_Fe_theory]) # np.insert(effective_diffusivity, [0,10],[diffusivity_Li2O_theory,diffusivity_Fe_theory])

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

label_list = ["16 grains", "49 grains", "100 grains", "144 grains"]
color_list = [1,2,0,3]
for i in range(num_micros):
    ax.plot(real_Fe_fraction_with_boundary[i], effective_diffusivity_with_boundary[i], '.', label=f"{label_list[i]}", c=f"C{color_list[i]}")
for i in range(num_micros):
    ax.plot(real_Fe_fraction_M2_with_boundary[i], effective_diffusivity_M2_with_boundary[i], 'o', markerfacecolor='none', label=r"non-smoothing " + f"{label_list[i]}", c=f"C{color_list[i]}")
ax.plot([0,1], [diffusivity_Fe_theory,diffusivity_Fe_theory], '--',c='gray')
ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Li2O_theory], '--',c='gray')
ax.text(0.35, 1.6e7, u'diffusivity of Li$_2$O',fontweight='bold',c=f"k")
ax.text(0.35, 9.5e8, u'diffusivity of Fe',fontweight='bold',c=f"k")
ax.set_xlabel(u'Fe phase fraction (-)')
ax.set_ylabel(u"Effective diffusivity (m$^2$/s)")
ax.legend(loc="best")
# ax.set_ylim(bottom=0)
plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../figures/multi_phases_effective_diffusivity_comparison_x_2D_0step.png', bbox_inches='tight', dpi=300)
plt.close(fig)


# ============================================================================ #
# Extract effective diffusivity in AEH model

# include first five experiment AEH from malachi
file_name_list_experiment = []
for i_micro in ["007", "010", "017", "025", "050"]:
    file_name_list_experiment.append(f'../AEH_files/AEH_experiment_microstructure_Fe_{i_micro}.csv')
experiment_AEH_malachi_num = int(len(file_name_list_experiment))
# 606 experiment AEH from mario,
for i_micro in ["010", "025", "050"]:
    for j_micro in range(202):
        file_name_list_experiment.append(f'../AEH_files/AEH_experiment_mario_microstructure_Fe_{i_micro}_slide_{j_micro:03}.csv')
experiment_AEH_mario_num = int(len(file_name_list_experiment) - experiment_AEH_malachi_num)
# one grain growth AEH from malachi
for i_micro in ["010"]:
    file_name_list_experiment.append(f'../AEH_files/AEH_Diffusion_Tritium_experiment_PF{i_micro}_output.csv')
growth_AEH_malachi_num = int(len(file_name_list_experiment) - experiment_AEH_malachi_num - experiment_AEH_mario_num)
# three grain growth AEH from mario
for i_micro in ["010", "025", "050"]:
    file_name_list_experiment.append(f'../AEH_files/AEH_Diffusion_Tritium_experiment_mario_PF{i_micro}_output.csv')
growth_AEH_mario_num = int(len(file_name_list_experiment) - experiment_AEH_malachi_num - experiment_AEH_mario_num - growth_AEH_malachi_num)
print(f"experiment case: {len(file_name_list_experiment)}")
# print(file_name_list_experiment)

experiment_results_list = []
effective_diffusivity_experiment = np.zeros(len(file_name_list_experiment))
real_Fe_fraction_experiment = np.zeros(len(file_name_list_experiment))
for i in range(len(file_name_list_experiment)):
    # experiment results
    file_name_exp = file_name_list_experiment[i]
    experiment_results = read_csv_from_TMAP8(file_name_exp, parameter_names) # read csv file
    effective_diffusivity_experiment[i] = experiment_results[parameter_names.index('D_x_AEH')][-1]
    real_Fe_fraction_experiment[i] = experiment_results[parameter_names.index('Fe_phase_fraction')][-1]

    experiment_results_list.append(experiment_results)
# print(real_Fe_fraction)

# ============================================================================ #
# Plot effective diffusivity

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

label_list = ["16 grains", "49 grains", "100 grains", "144 grains"]
color_list = [1,2,0,3]
for i in range(num_micros):
    ax.plot(real_Fe_fraction_with_boundary[i], effective_diffusivity_with_boundary[i], '.', label=r"D$_{eff}$ - " + f"{label_list[i]}", c=f"C{color_list[i]}")
# ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Fe_theory], '--', label=u"theory", c=f"C0")
ax.plot([0,1], [diffusivity_Fe_theory,diffusivity_Fe_theory], '--',c='gray')
ax.plot([0,1], [diffusivity_Li2O_theory,diffusivity_Li2O_theory], '--',c='gray')
ax.text(0.35, 1.6e7, u'diffusivity of Li$_2$O',fontweight='bold',c=f"k")
ax.text(0.35, 9.5e8, u'diffusivity of Fe',fontweight='bold',c=f"k")

num_one = int(experiment_AEH_malachi_num)
num_two = int(experiment_AEH_malachi_num + experiment_AEH_mario_num)
ax.plot(real_Fe_fraction_experiment[:num_one],
        effective_diffusivity_experiment[:num_one], '+', label="experimental \nmicrostructure (Malachi)",c='k')
ax.plot(real_Fe_fraction_experiment[num_one:num_two],
        effective_diffusivity_experiment[num_one:num_two], '.', label="experimental \nmicrostructure (Mario)",c='k')

ax.set_xlabel(u'Fe phase fraction (-)')
ax.set_ylabel(u"Effective diffusivity (m$^2$/s)")
ax.legend(loc="best")
# ax.set_ylim(bottom=0)
plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../figures/multi_phases_effective_diffusivity_comparison_x_2D_plus_experiment.png', bbox_inches='tight', dpi=300)

num_three = int(num_two + growth_AEH_malachi_num)
num_four = int(num_three + growth_AEH_mario_num)
ax.plot(real_Fe_fraction_experiment[num_two:num_three],
        effective_diffusivity_experiment[num_two:num_three], '+', label="smoothing experimental \nmicrostructure (Malachi)",c='C7')
ax.plot(real_Fe_fraction_experiment[num_three:num_four],
        effective_diffusivity_experiment[num_three:num_four], '.', label="smoothing experimental \nmicrostructure (Mario)",c='C7')

ax.legend(loc="best")
plt.savefig('../figures/multi_phases_effective_diffusivity_comparison_x_2D_plus_experiment_smoothing.png', bbox_inches='tight', dpi=300)

plt.close(fig)
