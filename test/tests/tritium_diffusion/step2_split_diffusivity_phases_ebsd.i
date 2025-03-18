# MOOSE input file
# Written by Lin Yang - Idaho National Laboratory
#
# Project:
# Meso-scale Modeling of Tritium Transport in Cermets
#
# Published with:
# ---
#
# Phase Field Model:   Isotropic diffusion equation
# type:                Steady-State
# Grain structure:     Polycrystals with two phases (Fe - Li2O)
# BCs:                 Periodic for AEH and fix for direct method
# System:              tritium diffusion in polycrystals including multi-phases
#
#
# Info:
# - multi-phases
#
# Units
# length: nm
# time: s
# energy: --
# quantity: --

# Physical constants
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h
T = '${units 1000 K}'
P = '${units 1e5 Pa}'

diffusivity_prefactor_Fe = '${units 1.9e-6 m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Fe = '${units 61300 J/mol}'
solubility_prefactor_Fe = '${units ${fparse 1.87e-6 / 3.016 * 55.845 * 4.04e28} at/m^3/Pa -> at/nm^3/Pa}' # at/m^3/Pa^0.5 -> at/nm^3/Pa^0.5
solubility_energy_Fe = '${units 8240 J/mol}'
diffusivity_prefactor_Li2O = '${units ${fparse exp(-5.93) * 1e-4} m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Li2O = '${units ${fparse 81.73 * 1e3} J/mol}'
solubility_prefactor_Li2O = '${units ${fparse 2.0568216e-05 * 4.04e28} at/m^3/Pa -> at/nm^3/Pa}' # at/m^3/Pa^0.5 -> at/nm^3/Pa^0.5
solubility_energy_Li2O = '${units ${fparse 1290 * R} J/mol}'

# Fe_fraction = "010"
# file_name = "Polycrystal_experiment_PF${Fe_fraction}.e"
# output_file_name = "AEH_Diffusion_Tritium_experiment_PF${Fe_fraction}_output"
# timestep_value = 1
# Fe_fraction = "010"
# timestep_value = 7
# Fe_fraction = "025"
# timestep_value = 8
Fe_fraction = "050"
timestep_value = 11
file_name = "Polycrystal_experiment_mario_PF${Fe_fraction}.e"
output_file_name = "AEH_Diffusion_Tritium_experiment_mario_PF${Fe_fraction}_output"


[Mesh]
  file = ${file_name}
[]

[UserObjects]
  [initial_grains]
    type = SolutionUserObject
    mesh = ${file_name}
    timestep = ${timestep_value}
  []
[]

[Variables]
  [cx_AEH] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
  [cy_AEH] #composition used for the y-component of the AEH solve
    initial_condition = 0.5
  []
[]

[BCs]
  [Periodic]
    [all]
      auto_direction = 'x y'
      variable = 'cx_AEH cy_AEH'
    []
  []
[]

[AuxVariables]
  [phase_numbers]
    order = FIRST
    family = LAGRANGE
  []
  [gr0]
    order = FIRST
    family = LAGRANGE
  []
  [gr1]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxKernels]
  [phase_numbers]
    type = SolutionAux
    execute_on = INITIAL
    variable = phase_numbers
    solution = initial_grains
    from_variable = phase_numbers
  []
  [init_grO]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr0
    solution = initial_grains
    from_variable = gr0
  []
  [init_gr1]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr1
    solution = initial_grains
    from_variable = gr1
  []
[]

[Kernels]
  [Diff_x]
    type = MatDiffusion
    diffusivity = diffusivity_in_phase
    variable = cx_AEH
  []
  [Diff_x_AEH]
    type = HomogenizedHeatConduction
    diffusion_coefficient = diffusivity_in_phase
    variable = cx_AEH
    component = 0
  []
  [Diff_y]
    type = MatDiffusion
    diffusivity = diffusivity_in_phase
    variable = cy_AEH
  []
  [Diff_y_AEH]
    type = HomogenizedHeatConduction
    diffusion_coefficient = diffusivity_in_phase
    variable = cy_AEH
    component = 1
  []
[]

[Materials]
  #====================================================== Diffusion coefficients
  #====================== Diffusion coefficients - Basic values and coefficients
  [Diffusivity_Fe] # bulk diffusivity contribution
    type = ParsedMaterial
    property_name = 'diffusivity_Fe'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Fe}     ${diffusivity_energy_Fe}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusivity_Li2O] # bulk diffusivity contribution
    type = ParsedMaterial
    property_name = 'diffusivity_Li2O'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Li2O}     ${diffusivity_energy_Li2O}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusion_in_phase]
    type = ParsedMaterial
    property_name = 'diffusivity_in_phase'
    coupled_variables = 'phase_numbers'
    material_property_names = 'diffusivity_Fe diffusivity_Li2O'
    expression = 'phase_numbers * diffusivity_Fe + (1 - phase_numbers) * diffusivity_Li2O'
    outputs = 'exodus'
  []
  [Solubility_Fe] # bulk diffusivity contribution
    type = ParsedMaterial
    property_name = 'solubility_Fe'
    constant_names = 'K0                              Es'
    constant_expressions = '${solubility_prefactor_Fe}     ${solubility_energy_Fe}'
    expression = 'K0 * exp(-Es / ${R} / ${T})'
  []
  [Solubility_Li2O] # bulk diffusivity contribution
    type = ParsedMaterial
    property_name = 'solubility_Li2O'
    constant_names = 'K0                              Es'
    constant_expressions = '${solubility_prefactor_Li2O}     ${solubility_energy_Li2O}'
    expression = 'K0 * exp(-Es / ${R} / ${T})'
  []
  [Solubility_in_phase]
    type = ParsedMaterial
    property_name = 'solubility_in_phase'
    coupled_variables = 'phase_numbers'
    material_property_names = 'solubility_Fe solubility_Li2O'
    expression = 'phase_numbers * solubility_Fe + (1 - phase_numbers) * solubility_Li2O'
    outputs = 'exodus'
  []
  [Concentration_in_BC]
    type = ParsedMaterial
    property_name = 'concentration_in_BC'
    material_property_names = 'solubility_in_phase'
    expression = 'solubility_in_phase * ${P} ^ 0.5'
    outputs = 'exodus'
  []
  [phase_Fe_field]
    type = ADParsedMaterial
    property_name = phase_Fe_field
    coupled_variables = 'phase_numbers'
    expression = 'if(phase_numbers>=0.5,1,0)'
    outputs = exodus
  []
  [phase_Li2O_field]
    type = ADParsedMaterial
    property_name = phase_Li2O_field
    coupled_variables = 'phase_numbers'
    expression = 'if(phase_numbers<0.5,1,0)'
    outputs = exodus
  []
[]

[Postprocessors]
  [D_x_AEH] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH cy_AEH'
    col = 0
    row = 0
    diffusion_coefficient = diffusivity_in_phase
    # execute_on = INITIAL
  []
  [D_y_AEH] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH cy_AEH'
    col = 1
    row = 1
    diffusion_coefficient = diffusivity_in_phase
    # execute_on = INITIAL
  []
  [effective_solubility]
    type = ElementAverageMaterialProperty
    mat_prop = solubility_in_phase
  []

  [solubility_Fe_theory]
    type = ElementAverageMaterialProperty
    mat_prop = solubility_Fe
  []
  [solubility_Li2O_theory]
    type = ElementAverageMaterialProperty
    mat_prop = solubility_Li2O
  []
  [concentration_bc_test]
    type = ElementAverageMaterialProperty
    mat_prop = concentration_in_BC
  []
  [diffusivity_Fe_theory]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Fe
  []
  [diffusivity_Li2O_theory]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Li2O
  []
  [Fe_phase_area]
    type = ADElementIntegralMaterialProperty
    mat_prop = 'phase_Fe_field'
    execute_on = 'initial timestep_end'
    outputs = exodus
  []
  [Li2O_phase_area]
    type = ADElementIntegralMaterialProperty
    mat_prop = 'phase_Li2O_field'
    execute_on = 'initial timestep_end'
    outputs = exodus
  []
  [Fe_phase_fraction]
    type = ParsedPostprocessor
    pp_names = 'Fe_phase_area Li2O_phase_area'
    expression = 'Fe_phase_area / (Fe_phase_area + Li2O_phase_area)'
    # outputs = exodus
  []
[]

# It converges faster if all the residuals are at the same magnitude
[Debug]
  show_var_residual_norms = true
[]

[Preconditioning]
  [SMP]
    type = SMP
    off_diag_row = 'cx_AEH cy_AEH'
    off_diag_column = 'cx_AEH cy_AEH'
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'

  # petsc_options = '-snes_ksp_ew'
  # petsc_options_iname = '-pc_type'
  # petsc_options_value = 'lu'
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu NONZERO'

  automatic_scaling = true
  compute_scaling_once = false
  l_max_its = 50
  nl_max_its = 50
  l_tol = 1e-04
  l_abs_tol = 1e-50
  nl_abs_tol = 1e-10
  nl_rel_tol = 1e-10
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
  file_base = ${output_file_name}
[]
