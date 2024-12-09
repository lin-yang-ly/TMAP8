import matplotlib.pyplot as plt
import numpy as np
from matplotlib import gridspec
import pandas as pd
from scipy import special
import scipy.stats as stats
import os

# Changes working directory to script directory (for consistent MooseDocs usage)
script_folder = os.path.dirname(__file__)
os.chdir(script_folder)

def interpolation_on_expected_input(date_x, data_y, expected_input):
    """Get new numerical solution based on the experimental input data points

    Args:
        expected_input (float): expected input data points
        date_x (float, ndarray): numerical input data points
        data_y (float, ndarray): numerical output data points

    Returns:
        float: updated expected output based on the data points in expected_input
    """
    left_limit = np.argwhere((np.diff(date_x < expected_input)))[0][0]
    right_limit = left_limit + 1
    return (expected_input - date_x[left_limit]) / (date_x[right_limit] - date_x[left_limit]) * (data_y[right_limit] - data_y[left_limit]) + data_y[left_limit]

# Read simulation data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/fuel_cycle/gold/fuel_cycle_update_out.csv"
else:                                  # if in test folder
    csv_folder = "./fuel_cycle_update_T_interval.csv"
simulation_data = pd.read_csv(csv_folder)
simulation_time = simulation_data['time']
simulation_total_tritium = simulation_data['total_tritium']
simulation_storage = simulation_data['T_10_storage']
simulation_ISS = simulation_data['T_09_ISS']
simulation_TES = simulation_data['T_02_TES']
# time unit - days
time_unit = 3600 * 24 # for days
simulation_time = simulation_time / time_unit

# double time
two_year = 3600 * 24 * 365 * 2 # s

# inflection point
inflection_y = np.min(simulation_storage)
inflection_x = simulation_time[np.argmin(simulation_storage)]
print(f"Inflection time = {inflection_x} days, and inventory = {inflection_y} kg")

# reserve inventory
tritium_burn_rate = 8.99e-7 # kg/s
TBE = 0.02
q = 0.25
t_res = 24 * 3600 # s
initial_inventory = 1.14 # kg
AF = 0.7
reserve_inventory = tritium_burn_rate / TBE * q * t_res * AF # we should consider AF in I_res as well
print(f"Required reserve inventory = {reserve_inventory} kg")
end_inventory = interpolation_on_expected_input(simulation_time, simulation_storage, two_year / time_unit)
print(f"End inventory = {end_inventory} ({round(end_inventory / initial_inventory, 2)} I_startup)")

file_base = 'fuel_cycle_baseline'
############################ recombination flux - atom/m$^2$/s ############################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(simulation_time, simulation_storage, linestyle='-', label=r"storage", c='tab:gray')
ax.plot(simulation_time, simulation_total_tritium, linestyle='-', label=r"total", c='k')
ax.plot(simulation_time, simulation_ISS, linestyle='-', label=r"ISS", c='tab:green')
ax.plot(simulation_time, simulation_TES, linestyle='-', label=r"TES", c='tab:blue')
ax.plot([two_year / time_unit, two_year / time_unit], [0.001, 1e2], linestyle='--', c='tab:gray')

ax.set_xlabel(u'time (days)')
ax.set_ylabel(u"Tritium Inventory (kg)")
ax.legend(loc="best")
ax.set_ylim(bottom=0.001,top=1e2)
ax.set_xlim(left=0.1)
plt.xscale('log')
plt.yscale('log')
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
ax.minorticks_on()
plt.savefig(f'{file_base}.png', bbox_inches='tight', dpi=300)
plt.close(fig)

############################################

# Read simulation data no pulse
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/fuel_cycle/gold/fuel_cycle_update_out.csv"
else:                                  # if in test folder
    csv_folder = "./fuel_cycle_update_analysis_no_pulse.csv"
simulation_data = pd.read_csv(csv_folder)
simulation_time_no_pulse = simulation_data['time']
simulation_BZ_no_pulse = simulation_data['T_01_BZ']
simulation_TES_no_pulse = simulation_data['T_02_TES']
simulation_ISS_no_pulse = simulation_data['T_09_ISS']
simulation_storage_no_pulse = simulation_data['T_10_storage']


# Read simulation data T interval
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/fuel_cycle/gold/fuel_cycle_update_out.csv"
else:                                  # if in test folder
    csv_folder = "./fuel_cycle_update_analysis_T_interval.csv"
simulation_data = pd.read_csv(csv_folder)
simulation_time_T_interval = simulation_data['time']
simulation_BZ_T_interval = simulation_data['T_01_BZ']
simulation_TES_T_interval = simulation_data['T_02_TES']
simulation_ISS_T_interval = simulation_data['T_09_ISS']
simulation_storage_T_interval = simulation_data['T_10_storage']

# Read experiment data
if "/TMAP8/doc/" in script_folder:     # if in documentation folder
    csv_folder = "../../../../test/tests/val-2a/gold/experiment_data_paper.csv"
else:                                  # if in test folder
    csv_folder = "./gold/inventory_paper.csv"
experiment_data = pd.read_csv(csv_folder)
experiment_time = experiment_data['time [s]']
experiment_BZ = experiment_data['blanket inventory [kg]']
experiment_TES = experiment_data['TES inventory [kg]']
experiment_ISS = experiment_data['ISS inventory [kg]']
experiment_storage = experiment_data['storage inventory [kg]']

# time unit - days
time_unit = 3600 * 24 # for days
simulation_time_no_pulse = simulation_time_no_pulse / time_unit
simulation_time_T_interval = simulation_time_T_interval / time_unit
experiment_time = experiment_time / time_unit

file_base = 'fuel_cycle_comparison'
############################ recombination flux - atom/m$^2$/s ############################
fig = plt.figure(figsize=[6.5, 5.5])
gs = gridspec.GridSpec(1, 1)
ax = fig.add_subplot(gs[0])

ax.plot(simulation_time_no_pulse, simulation_BZ_no_pulse, linestyle='-', label=r"no period", c='tab:red')
ax.plot(simulation_time_T_interval, simulation_BZ_T_interval, linestyle='-', label=r"period", c='tab:blue')
ax.plot(experiment_time, experiment_BZ, linestyle='--', label=r"Meschini 2023", c='grey')
ax.text(10, 5.5e-3, 'BZ',fontweight='bold')

ax.plot(simulation_time_no_pulse, simulation_TES_no_pulse, linestyle='-', c='tab:red')
ax.plot(simulation_time_T_interval, simulation_TES_T_interval, linestyle='-', c='tab:blue')
ax.plot(experiment_time, experiment_TES, linestyle='--', c='grey')
ax.text(10, 1e-1, 'TES',fontweight='bold')

ax.plot(simulation_time_no_pulse, simulation_ISS_no_pulse, linestyle='-', c='tab:red')
ax.plot(simulation_time_T_interval, simulation_ISS_T_interval, linestyle='-', c='tab:blue')
ax.plot(experiment_time, experiment_ISS, linestyle='--', c='grey')
ax.text(10, 2.05e-1, 'ISS',fontweight='bold')

ax.plot(simulation_time_no_pulse, simulation_storage_no_pulse, linestyle='-', c='tab:red')
ax.plot(simulation_time_T_interval, simulation_storage_T_interval, linestyle='-', c='tab:blue')
ax.plot(experiment_time, experiment_storage, linestyle='--', c='grey')
ax.text(10, 9.5e-1, 'storage',fontweight='bold')

ax.set_xlabel(u'time (days)')
ax.set_ylabel(u"Tritium Inventory (kg)")
ax.legend(loc="best",ncols=3)
ax.set_ylim(bottom=0.001,top=1e2)
ax.set_xlim(left=0.1)
plt.xscale('log')
plt.yscale('log')
plt.grid(visible=True, which='major', color='0.65', linestyle='--', alpha=0.3)
# new_simulation_storage_no_pulse = np.zeros(len(experiment_time))
# new_simulation_storage_T_interval = np.zeros(len(experiment_time))
# for i in range(len(experiment_time)):
#     new_simulation_storage_no_pulse[i] = interpolation_on_expected_input(simulation_time_no_pulse, simulation_storage_no_pulse, experiment_time[i])
#     new_simulation_storage_T_interval[i] = interpolation_on_expected_input(simulation_time_T_interval, simulation_storage_T_interval, experiment_time[i])
# RMSE_no_pulse = np.sqrt(np.mean((new_simulation_storage_no_pulse-experiment_storage)**2) )
# RMSPE_no_pulse = RMSE_no_pulse*100/np.mean(experiment_storage)
# ax.text(2,1, 'RMSPE = %.2f '%RMSPE_no_pulse+'%',fontweight='bold',c='tab:red')
# RMSE_T_interval = np.sqrt(np.mean((new_simulation_storage_T_interval-experiment_storage)**2) )
# RMSPE_T_interval = RMSE_T_interval*100/np.mean(experiment_storage)
# ax.text(2,1.5, 'RMSPE = %.2f '%RMSPE_T_interval+'%',fontweight='bold',c='tab:blue')
ax.minorticks_on()
plt.savefig(f'{file_base}.png', bbox_inches='tight', dpi=300)
plt.close(fig)
