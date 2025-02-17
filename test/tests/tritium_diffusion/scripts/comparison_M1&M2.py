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
################################# 2D EXTREME ###################################
################################################################################

parameter_names = ['time','point_value','mass_integral'] # s, atoms/nm^3

# ============================================================================ #
# Extract Fe and Li2O predictions in 2D model

file_name = '../gold/M1_Split_Tritium_Fe_output.csv'
M1_simulation_results_Fe = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
M1_simulation_results_Fe[parameter_names.index('point_value')] = M1_simulation_results_Fe[parameter_names.index('point_value')] * 1e18 # atoms/nm^3 -> atoms/m^3
file_name = '../gold/M1_Split_Tritium_Li2O_output.csv'
M1_simulation_results_Li2O = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
M1_simulation_results_Li2O[parameter_names.index('point_value')] = M1_simulation_results_Li2O[parameter_names.index('point_value')] * 1e18 # atoms/nm^3 -> atoms/m^3

file_name = '../gold/M2_Combine_Tritium_Fe_output.csv'
M2_simulation_results_Fe = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
M2_simulation_results_Fe[parameter_names.index('point_value')] = M2_simulation_results_Fe[parameter_names.index('point_value')] * 1e18 # atoms/nm^3 -> atoms/m^3
file_name = '../gold/M2_Combine_Tritium_Li2O_output.csv'
M2_simulation_results_Li2O = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
M2_simulation_results_Li2O[parameter_names.index('point_value')] = M2_simulation_results_Li2O[parameter_names.index('point_value')] * 1e18 # atoms/nm^3 -> atoms/m^3

# select only the simulation data for desorption
start_time = 0
end_time_Fe = 0.05
end_time_Fe_shorter = 3e-4
end_time_Li2O = 0.05
chosen_matrix = ((M1_simulation_results_Fe[parameter_names.index('time')]>=start_time)
                    & (M1_simulation_results_Fe[parameter_names.index('time')]<=end_time_Fe))
tmap_M1_time_Fe = M1_simulation_results_Fe[parameter_names.index('time')][chosen_matrix]
tmap_M1_point_Fe = M1_simulation_results_Fe[parameter_names.index('point_value')][chosen_matrix]
tmap_M1_point_Fe_shorter = M1_simulation_results_Fe[parameter_names.index('point_value')][(
    M1_simulation_results_Fe[parameter_names.index('time')]>=start_time)
    & (M1_simulation_results_Fe[parameter_names.index('time')]<=end_time_Fe_shorter)]

chosen_matrix = ((M1_simulation_results_Li2O[parameter_names.index('time')]>=start_time)
                    & (M1_simulation_results_Li2O[parameter_names.index('time')]<=end_time_Li2O))
tmap_M1_time_Li2O = M1_simulation_results_Li2O[parameter_names.index('time')][chosen_matrix]
tmap_M1_point_Li2O = M1_simulation_results_Li2O[parameter_names.index('point_value')][chosen_matrix]

chosen_matrix = ((M2_simulation_results_Fe[parameter_names.index('time')]>=start_time)
                    & (M2_simulation_results_Fe[parameter_names.index('time')]<=end_time_Fe))
tmap_M2_time_Fe = M2_simulation_results_Fe[parameter_names.index('time')][chosen_matrix]
tmap_M2_point_Fe = M2_simulation_results_Fe[parameter_names.index('point_value')][chosen_matrix]
tmap_M2_point_Fe_shorter = M2_simulation_results_Fe[parameter_names.index('point_value')][(
    M2_simulation_results_Fe[parameter_names.index('time')]>=start_time)
    & (M2_simulation_results_Fe[parameter_names.index('time')]<=end_time_Fe_shorter)]

chosen_matrix = ((M2_simulation_results_Li2O[parameter_names.index('time')]>=start_time)
                    & (M2_simulation_results_Li2O[parameter_names.index('time')]<=end_time_Li2O))
tmap_M2_time_Li2O = M2_simulation_results_Li2O[parameter_names.index('time')][chosen_matrix]
tmap_M2_point_Li2O = M2_simulation_results_Li2O[parameter_names.index('point_value')][chosen_matrix]

# ============================================================================ #
# Plot comparison between TMAP8 predictions and experimental data

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(tmap_M1_time_Fe, tmap_M1_point_Fe, label=r"M1 - Fe", c='tab:blue')
ax.plot(tmap_M2_time_Fe, tmap_M2_point_Fe, '--', label=r"M2 - Fe", c='tab:blue')
ax.plot(tmap_M1_time_Li2O, tmap_M1_point_Li2O, label=r"M1 - Li2O", c='tab:orange')
ax.plot(tmap_M2_time_Li2O, tmap_M2_point_Li2O, '--', label=r"M2 - Li2O", c='tab:orange')

ax.set_xlabel(u'Time (s)')
ax.set_ylabel(u"Tritium concentration (atom/m$^3$)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
# plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# tmap_flux_for_rmspe = numerical_solution_on_experiment_input(tmap_M2_time_Fe, tmap_M1_time_Fe, tmap_M1_point_Fe)
RMSE = np.sqrt(np.mean((tmap_M1_point_Fe_shorter-tmap_M2_point_Fe_shorter)**2) )
RMSPE = RMSE*100/np.mean(tmap_M2_point_Fe_shorter)
ax.text(0.0005,1.0e17, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
# tmap_flux_for_rmspe = numerical_solution_on_experiment_input(tmap_M2_time_Li2O, tmap_M1_time_Li2O, tmap_M1_point_Li2O)
RMSE = np.sqrt(np.mean((tmap_M1_point_Li2O-tmap_M2_point_Li2O)**2) )
RMSPE = RMSE*100/np.mean(tmap_M2_point_Li2O)
ax.text(0.0052,0.3e17, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.savefig('../figures/Fe_Li2O_M1_M2_point_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)


################################################################################
########################## 2D multi-phases multi-sizes #########################
################################################################################

parameter_names = ['time','point_value','mass_integral'] # s, atoms/nm^3, atom

# ============================================================================ #
# Extract Fe and Li2O predictions in 2D model

file_name_list_M1 = ['M1_Split_Tritium_D_2000_H_4_V_4_PF025_output.csv',
                    'M1_Split_Tritium_D_2000_H_4_V_4_PF075_output.csv',
                    'M1_Split_Tritium_D_2000_H_10_V_10_PF025_output.csv',
                    'M1_Split_Tritium_D_2000_H_10_V_10_PF075_output.csv']
file_name_list_M2 = ['M2_Combine_Tritium_D_2000_H_4_V_4_PF025_output.csv',
                    'M2_Combine_Tritium_D_2000_H_4_V_4_PF075_output.csv',
                    'M2_Combine_Tritium_D_2000_H_10_V_10_PF025_output.csv',
                    'M2_Combine_Tritium_D_2000_H_10_V_10_PF075_output.csv']

M1_simulation_results_list = []
M2_simulation_results_list = []
for i in range(len(file_name_list_M1)):
    # M1 results
    file_name_M1 = file_name_list_M1[i]
    M1_simulation_results = read_csv_from_TMAP8(file_name_M1, parameter_names) # read csv file
    M1_simulation_results[parameter_names.index('point_value')] = M1_simulation_results[parameter_names.index('point_value')] * 1e18 # atoms/nm^3 -> atoms/m^3
    M1_simulation_results_list.append(M1_simulation_results)
    # M2 results
    file_name_M2 = file_name_list_M2[i]
    M2_simulation_results = read_csv_from_TMAP8(file_name_M2, parameter_names) # read csv file
    M2_simulation_results[parameter_names.index('point_value')] = M2_simulation_results[parameter_names.index('point_value')] * 1e18 # atoms/nm^3 -> atoms/m^3
    M2_simulation_results_list.append(M2_simulation_results)

# select only the simulation data for desorption
start_time = 0
end_time = 0.05
tmap_M1_time_list = []
tmap_M2_time_list = []
tmap_M1_point_list = []
tmap_M2_point_list = []
tmap_M1_mass_list = []
tmap_M2_mass_list = []
for i in range(len(file_name_list_M1)):
    chosen_matrix_M1 = ((M1_simulation_results_list[i][parameter_names.index('time')] >= start_time)
                    & (M1_simulation_results_list[i][parameter_names.index('time')] <= end_time))
    tmap_M1_time = M1_simulation_results_list[i][parameter_names.index('time')][chosen_matrix_M1]
    tmap_M1_point = M1_simulation_results_list[i][parameter_names.index('point_value')][chosen_matrix_M1]
    tmap_M1_mass = M1_simulation_results_list[i][parameter_names.index('mass_integral')][chosen_matrix_M1]
    tmap_M1_time_list.append(tmap_M1_time)
    tmap_M1_point_list.append(tmap_M1_point)
    tmap_M1_mass_list.append(tmap_M1_mass)

    chosen_matrix_M2 = ((M2_simulation_results_list[i][parameter_names.index('time')] >= start_time)
                    & (M2_simulation_results_list[i][parameter_names.index('time')] <= end_time))
    tmap_M2_time = M2_simulation_results_list[i][parameter_names.index('time')][chosen_matrix_M2]
    tmap_M2_point = M2_simulation_results_list[i][parameter_names.index('point_value')][chosen_matrix_M2]
    tmap_M2_mass = M2_simulation_results_list[i][parameter_names.index('mass_integral')][chosen_matrix_M2]
    tmap_M2_time_list.append(tmap_M2_time)
    tmap_M2_point_list.append(tmap_M2_point)
    tmap_M2_mass_list.append(tmap_M2_mass)

# ============================================================================ #
# Plot comparison of M1 and M2 between TMAP8 predictions

# point
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
label_name = ["H4 V4 PF025", "H4 V4 PF075", "H10 V10 PF025", "H10 V10 PF075"]
for i in range(len(file_name_list_M1)):
    ax.plot(tmap_M1_time_list[i], tmap_M1_point_list[i], label=f"M1 - {label_name[i]}", c=f"C{i}")
for i in range(len(file_name_list_M2)):
    ax.plot(tmap_M2_time_list[i], tmap_M2_point_list[i], '--', label=f"M2 - {label_name[i]}", c=f"C{i}")


ax.set_xlabel(u'Time (s)')
ax.set_ylabel(u"Tritium concentration (atom/m$^3$)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
# plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# error
text_location = [[0.012,0.20e17],[0.01,1.41e17],[0.012,0.57e17],[0.01,1.18e17]]
for i in range(len(file_name_list_M1)):
    RMSE = np.sqrt(np.mean((tmap_M1_point_list[i]-tmap_M2_point_list[i])**2) )
    RMSPE = RMSE*100/np.mean(tmap_M2_point_list[i])
    ax.text(text_location[i][0],text_location[i][1 ], 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c=f"C{i}")
plt.savefig('../figures/multi_phases_M1_M2_point_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# mass_integral
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
for i in range(len(file_name_list_M1)):
    ax.plot(tmap_M1_time_list[i], tmap_M1_mass_list[i], label=f"M1 - {label_name[i]}", c=f"C{i}")
for i in range(len(file_name_list_M2)):
    ax.plot(tmap_M2_time_list[i], tmap_M2_mass_list[i], '--', label=f"M2 - {label_name[i]}", c=f"C{i}")
ax.set_xlabel(u'Time (s)')
ax.set_ylabel(u"Total mass (atom)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
# plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# error
text_location = [[0.014,1.4e5],[0.014,5.4e5],[0.014,2.6e5],[0.014,4.8e5]]
for i in range(len(file_name_list_M1)):
    RMSE = np.sqrt(np.mean((tmap_M1_mass_list[i]-tmap_M2_mass_list[i])**2) )
    RMSPE = RMSE*100/np.mean(tmap_M2_mass_list[i])
    ax.text(text_location[i][0],text_location[i][1 ], 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c=f"C{i}")
plt.savefig('../figures/multi_phases_M1_M2_mass_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# effective diffusivity
Fe_phase_fraction = np.array([0,0.25,0.75,1])
effective_diffusivity_M1_16grains = np.array([14308033.551062,22172807.194264,628611848.20157,1193528207.7975]) * 1e-18 # nm^2/s -> m^2/s
effective_diffusivity_M1_100grains = np.array([14308033.551062,25841146.513666,620332477.96492,1193528207.7975]) * 1e-18 # nm^2/s -> m^2/s
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax.plot(Fe_phase_fraction, effective_diffusivity_M1_16grains, label=f"M1 - 16 grains", c=f"C0")
ax.plot(Fe_phase_fraction, effective_diffusivity_M1_100grains, label=f"M1 - 100 grains", c=f"C1")
# for i in range(len(file_name_list_M2)):
#     ax.plot(tmap_M2_time_list[i], tmap_M2_mass_list[i], '--', label=f"M2 - {label_name[i]}", c=f"C{i}")
ax.set_xlabel(u'Fe phase fraction (-)')
ax.set_ylabel(u"Effective diffusivity (m$^2$/s)")
ax.legend(loc="best")
# ax.set_ylim(bottom=0)
plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
# error
# text_location = [[0.014,1.5e5],[0.014,5.4e5],[0.014,2.6e5],[0.014,4.8e5]]
# for i in range(len(file_name_list_M1)):
#     RMSE = np.sqrt(np.mean((tmap_M1_mass_list[i]-tmap_M2_mass_list[i])**2) )
#     RMSPE = RMSE*100/np.mean(tmap_M2_mass_list[i])
#     ax.text(text_location[i][0],text_location[i][1 ], 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold',c=f"C{i}")
plt.savefig('../figures/multi_phases_M1_M2_effective_diffusivity_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)


################################################################################
############################## 2D time efficiency ##############################
################################################################################

# Time for running M1 and M2 cases with different mesh size
M1_D2000_phase2_time = np.array([4.299, 4.645, 4.483, 4.432]) # s
M1_D2000_phase3_time = np.array([46.476, 43.269, 46.399, 45.799]) # s
M1_D1000_time = 1.349 + 11.937 # s
M1_D2000_time = np.mean(M1_D2000_phase2_time + M1_D2000_phase3_time)
M1_D4000_time = 18.079 + 3*60+33.292 # s

M2_D2000_phase2_time = np.array([2*60+0.851, 2*60+22.327, 2*60+7.802, 2*60+38.426]) # s
M2_D1000_time = 37.253
M2_D2000_time = np.mean(M2_D2000_phase2_time)
M2_D4000_time = 10*60+25.227

M1_time_list = [M1_D1000_time, M1_D2000_time, M1_D4000_time]
M2_time_list = [M2_D1000_time, M2_D2000_time, M2_D4000_time]
mesh_list = [1000,2000,4000]

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])


ax.plot(mesh_list, M1_time_list, '.-', label=f"M1", c=f"C0")
ax.plot(mesh_list, M2_time_list, '.-', label=f"M2", c=f"C1")


ax.set_xlabel(u'Mesh length (nm)')
ax.set_ylabel(u"Time (s)")
ax.legend(loc="best")
ax.set_ylim([10,1000])
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.set_xticks(mesh_list)
ax.set_yscale("log")
ax.set_xscale("log")
ax.minorticks_on()
plt.savefig('../figures/time_efficiency_M1_M2_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)
