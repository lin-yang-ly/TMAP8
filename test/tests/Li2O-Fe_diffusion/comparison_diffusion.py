import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
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

#===============================================================================
# Extract Fe and Li2O predictions

if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder_Fe = "../../../../test/tests/val-2b/gold/Fe_diffusion_1d_out.csv"
    csv_folder_Li2O = "../../../../test/tests/val-2b/gold/Li2O_diffusion_1d_out.csv"
else:                                  # if in test folder
    csv_folder_Fe = "./gold/Fe_diffusion_1d_out.csv"
    csv_folder_Li2O = "./gold/Li2O_diffusion_1d_out.csv"

tmap_solution_Fe = pd.read_csv(csv_folder_Fe)
tmap_time_Fe = tmap_solution_Fe['time'] # s
tmap_temperature_Fe = tmap_solution_Fe['temperature'] # K
tmap_pressure_Fe = tmap_solution_Fe['enclosure_pressure'] # Pa
tmap_flux_Fe = tmap_solution_Fe['avg_flux_total']*1e12 # atoms/microns^2/s -> atoms/m^2/s

tmap_solution_Li2O = pd.read_csv(csv_folder_Li2O)
tmap_time_Li2O = tmap_solution_Li2O['time'] # s
tmap_temperature_Li2O = tmap_solution_Li2O['temperature'] # K
tmap_pressure_Li2O = tmap_solution_Li2O['enclosure_pressure'] # Pa
tmap_flux_Li2O = tmap_solution_Li2O['avg_flux_total']*1e12 # atoms/microns^2/s -> atoms/m^2/s

# select only the simulation data for desorption
tmap_time_desorption_Fe = []
tmap_temperature_desorption_Fe = []
tmap_flux_desorption_Fe = []
for i in range(len(tmap_time_Fe)):
    if tmap_time_Fe[i]>=start_time_desorption:
        tmap_time_desorption_Fe.append(tmap_time_Fe[i])
        tmap_temperature_desorption_Fe.append(tmap_temperature_Fe[i])
        tmap_flux_desorption_Fe.append(tmap_flux_Fe[i])
tmap_time_desorption_Fe = np.array(tmap_time_desorption_Fe)
tmap_temperature_desorption_Fe = np.array(tmap_temperature_desorption_Fe)
tmap_flux_desorption_Fe = np.array(tmap_flux_desorption_Fe)

tmap_time_desorption_Li2O = []
tmap_temperature_desorption_Li2O = []
tmap_flux_desorption_Li2O = []
for i in range(len(tmap_time_Li2O)):
    if tmap_time_Li2O[i]>=start_time_desorption:
        tmap_time_desorption_Li2O.append(tmap_time_Li2O[i])
        tmap_temperature_desorption_Li2O.append(tmap_temperature_Li2O[i])
        tmap_flux_desorption_Li2O.append(tmap_flux_Li2O[i])
tmap_time_desorption_Li2O = np.array(tmap_time_desorption_Li2O)
tmap_temperature_desorption_Li2O = np.array(tmap_temperature_desorption_Li2O)
tmap_flux_desorption_Li2O = np.array(tmap_flux_desorption_Li2O)

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

ax2.plot(tmap_time_Fe/60/60, tmap_pressure_Fe, label=r"Pressure", c='r')
ax.plot(tmap_time_Fe/60/60, tmap_temperature_Fe, label=r"Temperature", c='b',ls='--')

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

plt.savefig('Fe_temperature_pressure_history.png', bbox_inches='tight', dpi=300)
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
plt.savefig('Fe_Li2O_comparison.png', bbox_inches='tight', dpi=300)
plt.close(fig)
