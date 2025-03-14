# MOOSE input file
# Written by Pierre-Clement Simon - Idaho National Laboratory
#
# Project:
# TRISO fuel fission gas transport: Silver diffusion in silicon carbide
#
# Published with:
# ---
#
# Phase Field Model:   Isotropic diffusion equation
# type:                Transient
# Grain structure:     Single grain
# BCs:                 Fixed value on the right, flux on the left
#
#
# Info:
# - Input file used to generate polycrystals for SiC
#
# Updates from previous file:
# -
#
# Units
# length: --
# time: --
# energy: --
# quantity: --

# This simulation predicts GB migration of a 3D copper polycrystal with 15 grains
# Mesh adaptivity (new system) and time step adaptivity are used
# An AuxVariable is used to calculate the grain boundary locations
# Postprocessors are used to record time step and the number of grains
# We are not using the GrainTracker in this example so the number
# of order paramaters must match the number of grains.

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

# figure_file_name = 'experiment_grayscale_figures/experiment_microstructure_Fe_050_phases.png'
# output_file_name = 'AEH_experiment_microstructure_Fe_050'
# figure_file_name = 'experiment_grayscale_figures/experiment_microstructure_Fe_025_phases.png'
# output_file_name = 'AEH_experiment_microstructure_Fe_025'
# figure_file_name = 'experiment_grayscale_figures/experiment_microstructure_Fe_010_phases.png'
# output_file_name = 'AEH_experiment_microstructure_Fe_010'
figure_file_name = 'experiment_grayscale_figures/experiment_mario_microstructure_Fe_050_phases.png'
output_file_name = 'AEH_experiment_mario_microstructure_Fe_050'

[Mesh]
  [image_mesh]
    type = ImageMeshGenerator
    dim = 2
    file = ${figure_file_name}
    scale_to_one = false
  []
[]

[ICs]
  [./Fe_ic]
    type = FunctionIC
    function = image_Fe
    variable = phase_Fe
  [../]
  [./Li2O_ic]
    type = FunctionIC
    function = image_Li2O
    variable = phase_Li2O
  [../]
[]

[Functions]
  [image_Li2O]
    type = ImageFunction
    file = ${figure_file_name}
    threshold = 256
    lower_value = 0
    upper_value = 1
  []
  [image_Fe]
    type = ImageFunction
    file = ${figure_file_name}
    threshold = 256
    lower_value = 1
    upper_value = 0
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

[AuxVariables]
  [phase_Fe]
  []
  [phase_Li2O]
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

[AuxKernels]
[]

[BCs]
  [Periodic]
    [all]
      auto_direction = 'x y'
      variable = 'cx_AEH cy_AEH'
    []
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
    coupled_variables = 'phase_Fe phase_Li2O'
    material_property_names = 'diffusivity_Fe diffusivity_Li2O'
    expression = 'phase_Fe * diffusivity_Fe + phase_Li2O * diffusivity_Li2O'
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
    coupled_variables = 'phase_Fe phase_Li2O'
    material_property_names = 'solubility_Fe solubility_Li2O'
    expression = 'phase_Fe * solubility_Fe + phase_Li2O * solubility_Li2O'
    # outputs = 'exodus'
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
    coupled_variables = 'phase_Fe'
    expression = 'phase_Fe'
    outputs = exodus
  []
  [phase_Li2O_field]
    type = ADParsedMaterial
    property_name = phase_Li2O_field
    coupled_variables = 'phase_Li2O'
    expression = 'phase_Li2O'
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

# [Adaptivity]
#   initial_steps = 1
#   max_h_level = 2
#   marker = bound_adapt
#   [Indicators]
#     [error]
#       type = GradientJumpIndicator
#       variable = bnds
#     []
#   []
#   [Markers]
#     [bound_adapt]
#       type = ValueThresholdMarker
#       third_state = DO_NOTHING
#       coarsen = 1.1 #0.999 #1.0
#       refine = 1.1 #0.95 #0.95
#       variable = bnds
#       invert = true
#     []
#     [errorfrac]
#       type = ErrorFractionMarker
#       coarsen = 0.1
#       indicator = error
#       refine = 0.7
#     []
#     [combined]
#       type = ComboMarker
#       markers = 'bound_adapt errorfrac'
#     []
#   []
# []

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
  csv = true
  perf_graph = true
  file_base = ${output_file_name}
  [console]
    type = Console
    max_rows = 10
  []
  [exodus]
    type = Exodus
    execute_on = 'INITIAL FINAL'
  []
[]
