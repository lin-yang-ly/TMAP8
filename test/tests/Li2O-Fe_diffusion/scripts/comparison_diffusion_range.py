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
        csv_folder = f"../../../../test/tests/Li2O-Fe_diffusion/{file_name}"
    else:                                  # if in test folder
        csv_folder = f"../{file_name}"
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
parameter_names = ['time','temperature','enclosure_pressure','avg_flux_total','diffusivity','solubility'] # s, K, Pa, atoms/microns^2/s
num_files = 14

simulation_results_Fe = []
for i in range(num_files):
    # Extract Fe and Li2O predictions in 1D model
    file_name = f'multiapp/Fe_results_runner{i:02}.csv'
    simulation_results_Fe_i = read_csv_from_TMAP8(file_name, parameter_names)
    simulation_results_Fe_i[parameter_names.index('avg_flux_total')] = simulation_results_Fe_i[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s
    # select only the simulation data for desorption
    simulation_results_Fe_i = simulation_results_Fe_i[:,simulation_results_Fe_i[parameter_names.index('time')]>=start_time_desorption]
    simulation_results_Fe.append(simulation_results_Fe_i)
simulation_results_Fe = np.array(simulation_results_Fe)

simulation_results_Li2O = []
for i in range(num_files):
    # Extract Fe and Li2O predictions in 1D model
    file_name = f'multiapp/Li2O_results_runner{i:02}.csv'
    simulation_results_Li2O_i = read_csv_from_TMAP8(file_name, parameter_names)
    simulation_results_Li2O_i[parameter_names.index('avg_flux_total')] = simulation_results_Li2O_i[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s
    # select only the simulation data for desorption
    simulation_results_Li2O_i = simulation_results_Li2O_i[:,simulation_results_Li2O_i[parameter_names.index('time')]>=start_time_desorption]
    simulation_results_Li2O.append(simulation_results_Li2O_i)
simulation_results_Li2O = np.array(simulation_results_Li2O)

#===============================================================================
# Plot comparison between TMAP8 predictions and experimental data

# diffusivity 0-6
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

label_list_Li2O = [""] * num_files
for i in range(int(num_files/2)): label_list_Li2O[i] = r"Li$_2$O - D $\times$ 10$^{" + f"{int(i - 3)}" + r"}$"
for i in range(int(num_files/2), num_files): label_list_Li2O[i] = r"Li$_2$O - D $\times$ 10$^{" + f"{int(i - 3 - num_files/2)}" + r"}$"
label_list_Fe = [""] * num_files
for i in range(int(num_files/2)): label_list_Fe[i] = r"Fe - D $\times$ 10$^{" + f"{int(i - 3)}" + r"}$"
for i in range(int(num_files/2), num_files): label_list_Fe[i] = r"Fe - D $\times$ 10$^{" + f"{int(i - 3 - num_files/2)}" + r"}$"
for i in range(int(num_files/2)):
    ax.plot(simulation_results_Fe[i][parameter_names.index('temperature')], simulation_results_Fe[i][parameter_names.index('avg_flux_total')], label=label_list_Fe[i], c='tab:blue', alpha = 1/1.5**i)
for i in range(int(num_files/2)):
    ax.plot(simulation_results_Li2O[i][parameter_names.index('temperature')], simulation_results_Li2O[i][parameter_names.index('avg_flux_total')], label=label_list_Li2O[i], c='tab:orange', alpha = 1/1.5**i)

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Tritium flux (atom/m$^2$/s)")
ax.legend(loc=(1.01,0.05),ncols=1)
ax.set_ylim(bottom=1e10,top=1e21)
ax.set_yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_comparison_diffusivity_range_log_1D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# solubility 7-13
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

for i in range(int(num_files/2),num_files):
    ax.plot(simulation_results_Fe[i][parameter_names.index('temperature')], simulation_results_Fe[i][parameter_names.index('avg_flux_total')], label=label_list_Fe[i], c='tab:blue', alpha = 1/1.5**(i-int(num_files/2)))
for i in range(int(num_files/2),num_files):
    ax.plot(simulation_results_Li2O[i][parameter_names.index('temperature')], simulation_results_Li2O[i][parameter_names.index('avg_flux_total')], label=label_list_Li2O[i], c='tab:orange', alpha = 1/1.5**(i-int(num_files/2)))

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Tritium flux (atom/m$^2$/s)")
ax.legend(loc=(1.01,0.05),ncols=1)
ax.set_ylim(bottom=1e10,top=1e21)
ax.set_yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_comparison_solubility_range_log_1D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ============================================================================ #
# Sensitivity analysis
diffusivity_range_Fe = np.log10(simulation_results_Fe[:,parameter_names.index('diffusivity'),0])
diffusivity_range_Li2O = np.log10(simulation_results_Li2O[:,parameter_names.index('diffusivity'),0])
solubility_range_Fe = np.log10(simulation_results_Fe[:,parameter_names.index('solubility'),0])
solubility_range_Li2O = np.log10(simulation_results_Li2O[:,parameter_names.index('solubility'),0])
max_flux_range_Fe = np.log10(np.max(simulation_results_Fe[:,parameter_names.index('avg_flux_total')], 1))
max_flux_range_Fe[np.isnan(max_flux_range_Fe)] = 0
max_flux_range_Li2O = np.log10(np.max(simulation_results_Li2O[:,parameter_names.index('avg_flux_total')], 1))
max_flux_range_Li2O[np.isnan(max_flux_range_Li2O)] = 0

diffusivity_sensitivity_Fe = np.average(abs(max_flux_range_Fe[1:int(num_files/2)] - max_flux_range_Fe[:int(num_files/2)-1])) / np.average(abs(diffusivity_range_Fe[1:int(num_files/2)] - diffusivity_range_Fe[:int(num_files/2)-1]))
solubility_sensitivity_Fe = np.average(abs(max_flux_range_Fe[int(num_files/2)+1:] - max_flux_range_Fe[int(num_files/2):-1])) / np.average(abs(solubility_range_Fe[int(num_files/2)+1:] - solubility_range_Fe[int(num_files/2):-1]))
diffusivity_sensitivity_Li2O = np.average(abs(max_flux_range_Li2O[1:int(num_files/2)] - max_flux_range_Li2O[:int(num_files/2)-1])) / np.average(abs(diffusivity_range_Li2O[1:int(num_files/2)] - diffusivity_range_Li2O[:int(num_files/2)-1]))
solubility_sensitivity_Li2O = np.average(abs(max_flux_range_Li2O[int(num_files/2)+1:] - max_flux_range_Li2O[int(num_files/2):-1])) / np.average(abs(solubility_range_Li2O[int(num_files/2)+1:] - solubility_range_Li2O[int(num_files/2):-1]))

normalized_sensitivity_Fe = np.array([diffusivity_sensitivity_Fe, solubility_sensitivity_Fe])/(diffusivity_sensitivity_Fe+solubility_sensitivity_Fe)
normalized_sensitivity_Li2O = np.array([diffusivity_sensitivity_Li2O, solubility_sensitivity_Li2O])/(diffusivity_sensitivity_Li2O+solubility_sensitivity_Li2O)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.bar(np.arange(2)-0.1, normalized_sensitivity_Fe, color = 'tab:blue', width = 0.2, label = "Fe")
ax.bar(np.arange(2)+0.1, normalized_sensitivity_Li2O, color = 'tab:orange', width = 0.2, label = "Li2O")

plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.set_ylim([0,1])
ax.set_xlabel(u'')
ax.set_ylabel(u"Sensitivity")
ax.set_xticks([0,1],["diffusivity", "solubility"])
ax.legend(loc="best")
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_sensitivity_1D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

################################################################################
################################# 2D DIFFUSION #################################
################################################################################

# ============================================================================ #
# Extract Fe and Li2O predictions in 2D model
parameter_names = ['time','temperature','enclosure_pressure','avg_flux_total','diffusivity','solubility'] # s, K, Pa, atoms/microns^2/s
num_files = 14

simulation_results_Fe = []
for i in range(num_files):
    # Extract Fe and Li2O predictions in 1D model
    file_name = f'multiapp_2d/Fe_results_runner{i:02}.csv'
    simulation_results_Fe_i = read_csv_from_TMAP8(file_name, parameter_names)
    simulation_results_Fe_i[parameter_names.index('avg_flux_total')] = simulation_results_Fe_i[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s
    # select only the simulation data for desorption
    simulation_results_Fe_i = simulation_results_Fe_i[:,simulation_results_Fe_i[parameter_names.index('time')]>=start_time_desorption]
    simulation_results_Fe.append(simulation_results_Fe_i)
simulation_results_Fe = np.array(simulation_results_Fe)

simulation_results_Li2O = []
for i in range(num_files):
    # Extract Fe and Li2O predictions in 1D model
    file_name = f'multiapp_2d/Li2O_results_runner{i:02}.csv'
    simulation_results_Li2O_i = read_csv_from_TMAP8(file_name, parameter_names)
    simulation_results_Li2O_i[parameter_names.index('avg_flux_total')] = simulation_results_Li2O_i[parameter_names.index('avg_flux_total')] * 1e12 # atoms/microns^2/s -> atoms/m^2/s
    # select only the simulation data for desorption
    simulation_results_Li2O_i = simulation_results_Li2O_i[:,simulation_results_Li2O_i[parameter_names.index('time')]>=start_time_desorption]
    simulation_results_Li2O.append(simulation_results_Li2O_i)
simulation_results_Li2O = np.array(simulation_results_Li2O)

# ============================================================================ #
# Plot comparison between TMAP8 predictions and experimental data

# diffusivity 0-6
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

label_list_Li2O = [""] * num_files
for i in range(int(num_files/2)): label_list_Li2O[i] = r"Li$_2$O - D $\times$ 10$^{" + f"{int(i - 3)}" + r"}$"
for i in range(int(num_files/2), num_files): label_list_Li2O[i] = r"Li$_2$O - D $\times$ 10$^{" + f"{int(i - 3 - num_files/2)}" + r"}$"
label_list_Fe = [""] * num_files
for i in range(int(num_files/2)): label_list_Fe[i] = r"Fe - D $\times$ 10$^{" + f"{int(i - 3)}" + r"}$"
for i in range(int(num_files/2), num_files): label_list_Fe[i] = r"Fe - D $\times$ 10$^{" + f"{int(i - 3 - num_files/2)}" + r"}$"
for i in range(int(num_files/2)):
    ax.plot(simulation_results_Fe[i][parameter_names.index('temperature')], simulation_results_Fe[i][parameter_names.index('avg_flux_total')], label=label_list_Fe[i], c='tab:blue', alpha = 1/1.5**i)
for i in range(int(num_files/2)):
    ax.plot(simulation_results_Li2O[i][parameter_names.index('temperature')], simulation_results_Li2O[i][parameter_names.index('avg_flux_total')], label=label_list_Li2O[i], c='tab:orange', alpha = 1/1.5**i)

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Tritium flux (atom/m$^2$/s)")
ax.legend(loc=(1.01,0.05),ncols=1)
ax.set_ylim(bottom=1e10,top=1e21)
ax.set_yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_comparison_diffusivity_range_log_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# solubility 7-13
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

for i in range(int(num_files/2),num_files):
    ax.plot(simulation_results_Fe[i][parameter_names.index('temperature')], simulation_results_Fe[i][parameter_names.index('avg_flux_total')], label=label_list_Fe[i], c='tab:blue', alpha = 1/1.5**(i-int(num_files/2)))
for i in range(int(num_files/2),num_files):
    ax.plot(simulation_results_Li2O[i][parameter_names.index('temperature')], simulation_results_Li2O[i][parameter_names.index('avg_flux_total')], label=label_list_Li2O[i], c='tab:orange', alpha = 1/1.5**(i-int(num_files/2)))

ax.set_xlabel(u'Temperature (K)')
ax.set_ylabel(u"Tritium flux (atom/m$^2$/s)")
ax.legend(loc=(1.01,0.05),ncols=1)
ax.set_ylim(bottom=1e10,top=1e21)
ax.set_yscale("log")
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_comparison_solubility_range_log_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)

# ============================================================================ #
# Sensitivity analysis
diffusivity_range_Fe = np.log10(simulation_results_Fe[:,parameter_names.index('diffusivity'),0])
diffusivity_range_Li2O = np.log10(simulation_results_Li2O[:,parameter_names.index('diffusivity'),0])
solubility_range_Fe = np.log10(simulation_results_Fe[:,parameter_names.index('solubility'),0])
solubility_range_Li2O = np.log10(simulation_results_Li2O[:,parameter_names.index('solubility'),0])
max_flux_range_Fe = np.log10(np.max(simulation_results_Fe[:,parameter_names.index('avg_flux_total')], 1))
max_flux_range_Fe[np.isnan(max_flux_range_Fe)] = 0
max_flux_range_Li2O = np.log10(np.max(simulation_results_Li2O[:,parameter_names.index('avg_flux_total')], 1))
max_flux_range_Li2O[np.isnan(max_flux_range_Li2O)] = 0

diffusivity_sensitivity_Fe = np.average(abs(max_flux_range_Fe[1:int(num_files/2)] - max_flux_range_Fe[:int(num_files/2)-1])) / np.average(abs(diffusivity_range_Fe[1:int(num_files/2)] - diffusivity_range_Fe[:int(num_files/2)-1]))
solubility_sensitivity_Fe = np.average(abs(max_flux_range_Fe[int(num_files/2)+1:] - max_flux_range_Fe[int(num_files/2):-1])) / np.average(abs(solubility_range_Fe[int(num_files/2)+1:] - solubility_range_Fe[int(num_files/2):-1]))
diffusivity_sensitivity_Li2O = np.average(abs(max_flux_range_Li2O[1:int(num_files/2)] - max_flux_range_Li2O[:int(num_files/2)-1])) / np.average(abs(diffusivity_range_Li2O[1:int(num_files/2)] - diffusivity_range_Li2O[:int(num_files/2)-1]))
solubility_sensitivity_Li2O = np.average(abs(max_flux_range_Li2O[int(num_files/2)+1:] - max_flux_range_Li2O[int(num_files/2):-1])) / np.average(abs(solubility_range_Li2O[int(num_files/2)+1:] - solubility_range_Li2O[int(num_files/2):-1]))

normalized_sensitivity_Fe = np.array([diffusivity_sensitivity_Fe, solubility_sensitivity_Fe])/(diffusivity_sensitivity_Fe+solubility_sensitivity_Fe)
normalized_sensitivity_Li2O = np.array([diffusivity_sensitivity_Li2O, solubility_sensitivity_Li2O])/(diffusivity_sensitivity_Li2O+solubility_sensitivity_Li2O)

fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.bar(np.arange(2)-0.1, normalized_sensitivity_Fe, color = 'tab:blue', width = 0.2, label = "Fe")
ax.bar(np.arange(2)+0.1, normalized_sensitivity_Li2O, color = 'tab:orange', width = 0.2, label = "Li2O")

plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.set_ylim([0,1])
ax.set_xlabel(u'')
ax.set_ylabel(u"Sensitivity")
ax.set_xticks([0,1],["diffusivity", "solubility"])
ax.legend(loc="best")
ax.minorticks_on()
plt.savefig('../python_figures/Fe_Li2O_sensitivity_2D.png', bbox_inches='tight', dpi=300)
plt.close(fig)
