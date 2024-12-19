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

temperature_desorption_min = 300 # K
temperature_desorption_max = 1073 # K
desorption_heating_rate = 3/60 # K/minutes -> K/s
charge_time = 50*60*60 # h -> s
# We use a 5 hour cooldown period to let the temperature decrease to around 300 K for the start of the desorption.
# Which is same with the period in val-2b
cooldown_duration = 5*60*60 # h -> s
start_time_desorption = charge_time + cooldown_duration
desorption_duration = (temperature_desorption_max-temperature_desorption_min)/desorption_heating_rate
endtime = charge_time + cooldown_duration + desorption_duration

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
################################# 1D DIFFUSION #################################
################################################################################

#===============================================================================
# Extract Fe and Li2O predictions in 1D model
parameter_names = ['time','temperature','enclosure_pressure','avg_flux_total'] # s, K, Pa, atoms/microns^2/s
file_name = 'Fe_diffusion_1d_out.csv'
simulation_results_Fe = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results_Fe[parameter_names.index('avg_flux_total')] = simulation_results_Fe[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s
file_name = 'Li2O_diffusion_1d_out.csv'
simulation_results_Li2O = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results_Li2O[parameter_names.index('avg_flux_total')] = simulation_results_Li2O[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s

# select only the simulation data for desorption
chosen_matrix = simulation_results_Fe[parameter_names.index('time')]>=start_time_desorption
tmap_time_desorption_Fe = simulation_results_Fe[parameter_names.index('time')][chosen_matrix]
tmap_temperature_desorption_Fe = simulation_results_Fe[parameter_names.index('temperature')][chosen_matrix]
tmap_flux_desorption_Fe = simulation_results_Fe[parameter_names.index('avg_flux_total')][chosen_matrix]

chosen_matrix = simulation_results_Li2O[parameter_names.index('time')]>=start_time_desorption
tmap_time_desorption_Li2O = simulation_results_Li2O[parameter_names.index('time')][chosen_matrix]
tmap_temperature_desorption_Li2O = simulation_results_Li2O[parameter_names.index('temperature')][chosen_matrix]
tmap_flux_desorption_Li2O = simulation_results_Li2O[parameter_names.index('avg_flux_total')][chosen_matrix]

#===============================================================================
# Extract experimental data

# if "/TMAP8/doc/" in script_folder:     # if in documentation folder
#     csv_folder = "../../../../test/tests/val-2b/gold/experimental_data.csv"
# else:                                  # if in test folder
#     csv_folder = "./gold/experimental_data.csv"
# experiment_data = pd.read_csv(csv_folder)
# experiment_temperature = experiment_data['temperature (C)'] + 273.15 # conversion from C to Kelvin
# experiment_flux = experiment_data['flux (atoms/mm^2/s x 10^10)'] * 1e10 * 1e6 # conversion from (atoms/mm^2/s x 10^10) to (atom/m$^2$/s)

#===============================================================================
# Plot temperature and pressure history

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])
ax2 = ax.twinx()

ax2.plot(simulation_results_Fe[parameter_names.index('time')]/3600,
            simulation_results_Fe[parameter_names.index('enclosure_pressure')], label=r"Pressure", c='r')
ax.plot(simulation_results_Fe[parameter_names.index('time')]/3600,
            simulation_results_Fe[parameter_names.index('temperature')], label=r"Temperature", c='b',ls='--')

ax.set_xlabel(u'Time (h)')
ax.set_ylabel(u"Temperature (K)", c='b')
ax.legend(loc="lower left")
ax.set_ylim(bottom=0)
ax.set_xlim(left=0, right=endtime/60/60)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()

ax2.set_ylabel(u"Pressure (Pa)", c='r')
ax2.legend(loc="lower center")
ax2.set_xlim(left=0)
ax2.set_yscale('log')
ax2.minorticks_on()

plt.savefig('../python_figures/Fe_temperature_pressure_history.png', bbox_inches='tight', dpi=300)
plt.close(fig)

#===============================================================================
# Plot comparison between TMAP8 predictions and experimental data

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# ax.scatter(experiment_temperature, experiment_flux,label=r"Experiment", c='k', marker='^')
ax.plot(tmap_temperature_desorption_Fe, tmap_flux_desorption_Fe, label=r"Fe", c='tab:blue')
ax.plot(tmap_temperature_desorption_Li2O, tmap_flux_desorption_Li2O, label=r"Li2O", c='tab:orange')

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Tritium flux (atom/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_comparison_1D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
################################# 2D DIFFUSION #################################
################################################################################

# ============================================================================ #
# Extract Fe and Li2O predictions in 2D model

file_name = 'Fe_diffusion_2d_out.csv'
simulation_results_Fe = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results_Fe[parameter_names.index('avg_flux_total')] = simulation_results_Fe[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s
file_name = 'Li2O_diffusion_2d_out.csv'
simulation_results_Li2O = read_csv_from_TMAP8(file_name, parameter_names) # read csv file
simulation_results_Li2O[parameter_names.index('avg_flux_total')] = simulation_results_Li2O[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s

# select only the simulation data for desorption
chosen_matrix = simulation_results_Fe[parameter_names.index('time')]>=start_time_desorption
tmap_time_desorption_Fe = simulation_results_Fe[parameter_names.index('time')][chosen_matrix]
tmap_temperature_desorption_Fe = simulation_results_Fe[parameter_names.index('temperature')][chosen_matrix]
tmap_flux_desorption_Fe = simulation_results_Fe[parameter_names.index('avg_flux_total')][chosen_matrix]

chosen_matrix = simulation_results_Li2O[parameter_names.index('time')]>=start_time_desorption
tmap_time_desorption_Li2O = simulation_results_Li2O[parameter_names.index('time')][chosen_matrix]
tmap_temperature_desorption_Li2O = simulation_results_Li2O[parameter_names.index('temperature')][chosen_matrix]
tmap_flux_desorption_Li2O = simulation_results_Li2O[parameter_names.index('avg_flux_total')][chosen_matrix]

# ============================================================================ #
# Plot comparison between TMAP8 predictions and experimental data

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

# ax.scatter(experiment_temperature, experiment_flux,label=r"Experiment", c='k', marker='^')
ax.plot(tmap_temperature_desorption_Fe, tmap_flux_desorption_Fe, label=r"Fe", c='tab:blue')
ax.plot(tmap_temperature_desorption_Li2O, tmap_flux_desorption_Li2O, label=r"Li2O", c='tab:orange')

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Tritium flux (atom/m$^2$/s)")
ax.legend(loc="best")
ax.set_ylim(bottom=0)
# plt.yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_comparison_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)
