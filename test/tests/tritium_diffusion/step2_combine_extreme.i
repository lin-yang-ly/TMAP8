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
solubility_order = 0.5
file_name = "gold/Polycrystal_Domain_2000_NumGrainHor_4_NumGrainVert_4_PF025.e-s002"

[Mesh]
  [exodus_mesh]
    type = FileMeshGenerator
    file = ${file_name}
  []
[]

[UserObjects]
  [initial_grains]
    type = SolutionUserObject
    mesh = ${file_name}
    timestep = LATEST
  []
[]

[Variables]
  [concentration] # concentration in cermets
    initial_condition = 0.0
  []
[]

[AuxVariables]
  [phase_numbers]
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
[]

[Kernels]
  [dc_dt]
    type = TimeDerivative
    variable = concentration
  []
  [Diff_c]
    type = MatDiffusion
    variable = concentration
    diffusivity = diffusivity_Fe
  []
[]

[BCs]
  [left_right_flux]
    type = EquilibriumBC
    Ko = ${solubility_prefactor_Fe}
    activation_energy = '${solubility_energy_Fe}'
    boundary = 'left right'
    enclosure_var = ${P}
    temperature = ${T}
    variable = concentration
    p = ${solubility_order}
  []
  # [bottom_top_flux]
  #   type = ADNeumannBC
  #   value = 0
  #   boundary = 'top bottom'
  #   variable = concentration
  # []
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
    expression = '(2 - phase_numbers) * diffusivity_Fe + (phase_numbers - 1) * diffusivity_Li2O'
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
    expression = '(2 - phase_numbers) * solubility_Fe + (phase_numbers - 1) * solubility_Li2O'
    # outputs = 'exodus'
  []
  [Concentration_in_BC]
    type = ParsedMaterial
    property_name = 'concentration_in_BC'
    material_property_names = 'solubility_in_phase'
    expression = 'solubility_in_phase * ${P} ^ ${solubility_order}'
    outputs = 'exodus'
  []
[]

[Postprocessors]
  [diffusivity_Fe_theory]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Fe
  []
  [diffusivity_Li2O_theory]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Li2O
  []
  [point_value]
    type = PointValue
    point = "-10 -10 0"
    variable = concentration
  []
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = 'diffusivity_Fe'
    boundary = 'left'
    # outputs = none
  []
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = 'diffusivity_Fe'
    boundary = 'right'
    # outputs = none
  []
  [mass_integral]
    type = ElementIntegralVariablePostprocessor
    variable = concentration
  []
[]

# It converges faster if all the residuals are at the same magnitude
[Debug]
  show_var_residual_norms = true
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-12
  end_time = 5e-2
  dtmax = 1
  automatic_scaling = true
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 12
    iteration_window = 1
    growth_factor = 1.1
    dt = 1e-7 # 2.37e-7
    cutback_factor = 0.9
    cutback_factor_at_failure = 0.9
  []
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
  file_base = 'M2_Combine_Tritium_Fe_output'
[]
