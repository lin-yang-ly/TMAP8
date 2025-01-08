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
file_name = "gold/Polycrystal_Domain_1000_NumGrainHor_4_NumGrainVert_4.e-s002"

[Mesh]
  file = ${file_name}
[]

[GlobalParams]
  op_num = 8
  var_name_base = gr
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

[BCs]
  # [BC_flux]
  #   type = FunctionDirichletBC
  #   function = 0 #concentration_in_BC
  #   boundary = 'left right top bottom'
  #   variable = concentration
  # []
  [BC_flux]
    type = FunctorDirichletBC
    functor = concentration_in_BC
    boundary = 'left right top bottom'
    variable = concentration
  []
[]

[AuxVariables]
  # [cy_AEH] #composition used for the x-component of the AEH solve
  #   order = FIRST
  #   family = LAGRANGE
  # []
  [phase_numbers]
    order = FIRST
    family = LAGRANGE
  []
  [phase_Fe]
    order = FIRST
    family = LAGRANGE
  []
  [phase_Li2O]
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
  [gr2]
    order = FIRST
    family = LAGRANGE
  []
  [gr3]
    order = FIRST
    family = LAGRANGE
  []
  [gr4]
    order = FIRST
    family = LAGRANGE
  []
  [gr5]
    order = FIRST
    family = LAGRANGE
  []
  [gr6]
    order = FIRST
    family = LAGRANGE
  []
  [gr7]
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
  [phase_Fe]
    # Calculate the bnds for specific GB type
    type = SolutionAuxMisorientationBoundary
    variable = phase_Fe
    gb_type_order = 1
    solution = initial_grains
    from_variable = phase_numbers
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [phase_Li2O]
    # Calculate the bnds for specific GB type
    type = SolutionAuxMisorientationBoundary
    variable = phase_Li2O
    gb_type_order = 2
    solution = initial_grains
    from_variable = phase_numbers
    execute_on = 'INITIAL TIMESTEP_END'
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
  [init_gr2]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr2
    solution = initial_grains
    from_variable = gr2
  []
  [init_gr3]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr3
    solution = initial_grains
    from_variable = gr3
  []
  [init_gr4]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr4
    solution = initial_grains
    from_variable = gr4
  []
  [init_gr5]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr5
    solution = initial_grains
    from_variable = gr5
  []
  [init_gr6]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr6
    solution = initial_grains
    from_variable = gr6
  []
  [init_gr7]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr7
    solution = initial_grains
    from_variable = gr7
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
    diffusivity = diffusivity_in_phase
  []
[]

[Materials]
  #====================================================== Diffusion coefficients
  #====================== Diffusion coefficients - Basic values and coefficients
  [Diffusion_coefficient_diffusivity_Fe] # bulk diffusivity contribution
    type = ParsedMaterial
    property_name = 'diffusivity_Fe'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Fe}     ${diffusivity_energy_Fe}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusion_coefficient_diffusivity_Li2O] # bulk diffusivity contribution
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
  # [Diffusion_in_phase]
  #   type = ParsedMaterial
  #   f_name = 'diffusivity_in_phase'
  #   material_property_names = 'diffusivity_Fe diffusivity_Li2O'
  #   function = 'diffusivity_Li2O'
  #   outputs = exodus
  # []
  [Diffusion_coefficient_solubility_Fe] # bulk diffusivity contribution
    type = ParsedMaterial
    property_name = 'solubility_Fe'
    constant_names = 'K0                              Es'
    constant_expressions = '${solubility_prefactor_Fe}     ${solubility_energy_Fe}'
    expression = 'K0 * exp(-Es / ${R} / ${T})'
  []
  [Diffusion_coefficient_solubility_Li2O] # bulk diffusivity contribution
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
  [Surface_tot]
    type = ElementIntegralMaterialProperty
    mat_prop = 1
  []
[]

# It converges faster if all the residuals are at the same magnitude
[Debug]
  show_var_residual_norms = true
[]

[Executioner]
  type = Transient
  scheme = bdf2

  nl_rel_tol = 1e-10
  end_time = 2000
  dtmax = 50
  nl_max_its = 14
  [TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 12
    iteration_window = 1
    growth_factor = 1.2
    dt = 0.1 # 2.37e-7
    cutback_factor = 0.75
    cutback_factor_at_failure = 0.75
  []
[]

[Outputs]
  exodus = true
  perf_graph = true
  csv = true
  file_base = 'Diffusion_Polycrystal_Tritium_output'
[]
