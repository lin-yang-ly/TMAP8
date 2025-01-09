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

parameter_names = ['time','point_value'] # s, K, Pa, atoms/microns^2/s

################################################################################
################################# 2D DIFFUSION #################################
################################################################################

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
end_time_Fe = 0.01
end_time_Fe_shorter = 3e-4
end_time_Li2O = 0.01
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
ax.text(0.0052,0.6e17, 'RMSPE = %.2f '%RMSPE+'%',fontweight='bold')
plt.savefig('../figures/Fe_Li2O_M1_M2_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)
