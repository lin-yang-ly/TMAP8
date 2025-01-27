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
figure_file_name = "D2000_H4_V4_PF025_phases.png"
output_file_name = "M2_Combine_Tritium_D_2000_H_4_V_4_PF025_output"

jump_penalty = 1e2 # (-)

[Mesh]
  [exodus_mesh]
    type = FileMeshGenerator
    file = ${file_name}
  []
  [image]
    input = exodus_mesh
    type = ImageSubdomainGenerator
    file = ${figure_file_name}
    threshold = 150
  []
  [interface_Fe]
    type = SideSetsBetweenSubdomainsGenerator
    input = image
    primary_block = '0' # Fe
    paired_block = '1' # Li2O
    new_boundary = 'interface_Fe'
  []
  [interface_Li2O]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface_Fe
    primary_block = '1' # Li2O
    paired_block = '0' # Fe
    new_boundary = 'interface_Li2O'
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
  [concentration_Fe] # concentration in cermets
    initial_condition = 0.0
    block = 0
  []
  [concentration_Li2O] # concentration in cermets
    initial_condition = 0.0
    block = 1
  []
[]

[BCs]
  # [BC_flux]
  #   type = FunctionDirichletBC
  #   function = 0 #concentration_in_BC
  #   boundary = 'left right top bottom'
  #   variable = concentration
  # []
  # [left_right_BC_Fe]
  #   type = ADFunctorDirichletBC
  #   functor = concentration_in_BC
  #   boundary = 'left right'
  #   variable = concentration_Fe
  # []
  [left_right_BC_Fe]
    type = ADFunctionDirichletBC
    function = concentration_in_BC_Fe_func
    boundary = 'left right'
    variable = concentration_Fe
    block = 0
  []
  [top_bottom_BC_Fe]
    type = ADNeumannBC
    value = 0
    boundary = 'top bottom'
    variable = concentration_Fe
    block = 0
  []
  # [left_right_BC_Li2O]
  #   type = ADFunctorDirichletBC
  #   functor = concentration_in_BC
  #   boundary = 'left right'
  #   variable = concentration_Li2O
  # []
  [left_right_BC_Li2O]
    type = ADFunctionDirichletBC
    functor = concentration_in_BC_Li2O_func
    boundary = 'left right'
    variable = concentration_Li2O
    block = 1
  []
  [top_bottom_BC_Li2O]
    type = ADNeumannBC
    value = 0
    boundary = 'top bottom'
    variable = concentration_Li2O
    block = 1
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
  [dc_dt_Fe]
    type = ADTimeDerivative
    variable = concentration_Fe
    block = 0
  []
  [Diff_c_Fe]
    type = ADMatDiffusion
    variable = concentration_Fe
    diffusivity = diffusivity_in_phase
    block = 0
  []
  [dc_dt_Li2O]
    type = ADTimeDerivative
    variable = concentration_Li2O
    block = 1
  []
  [Diff_c_Li2O]
    type = ADMatDiffusion
    variable = concentration_Li2O
    diffusivity = diffusivity_in_phase
    block = 1
  []
[]

[InterfaceKernels]
  [tied]
    type = ADPenaltyInterfaceDiffusion
    variable = concentration_Fe
    neighbor_var = concentration_Li2O
    penalty = ${jump_penalty}
    jump_prop_name = solubility_ratio
    boundary = 'interface_Fe'
  []
[]

[Materials]
  #====================================================== Diffusion coefficients
  #====================== Diffusion coefficients - Basic values and coefficients
  [Diffusivity_Fe] # bulk diffusivity contribution
    type = ADParsedMaterial
    property_name = 'diffusivity_Fe'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Fe}     ${diffusivity_energy_Fe}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusivity_Li2O] # bulk diffusivity contribution
    type = ADParsedMaterial
    property_name = 'diffusivity_Li2O'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Li2O}     ${diffusivity_energy_Li2O}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusion_in_phase]
    type = ADParsedMaterial
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
  [Solubility_Fe] # bulk diffusivity contribution
    type = ADParsedMaterial
    property_name = 'solubility_Fe'
    constant_names = 'K0                              Es'
    constant_expressions = '${solubility_prefactor_Fe}     ${solubility_energy_Fe}'
    expression = 'K0 * exp(-Es / ${R} / ${T})'
  []
  [Solubility_Li2O] # bulk diffusivity contribution
    type = ADParsedMaterial
    property_name = 'solubility_Li2O'
    constant_names = 'K0                              Es'
    constant_expressions = '${solubility_prefactor_Li2O}     ${solubility_energy_Li2O}'
    expression = 'K0 * exp(-Es / ${R} / ${T})'
  []
  [Solubility_in_phase]
    type = ADParsedMaterial
    property_name = 'solubility_in_phase'
    coupled_variables = 'phase_numbers'
    material_property_names = 'solubility_Fe solubility_Li2O'
    expression = '(2 - phase_numbers) * solubility_Fe + (phase_numbers - 1) * solubility_Li2O'
    # outputs = 'exodus'
  []
  [Concentration_in_BC]
    type = ADParsedMaterial
    property_name = 'concentration_in_BC'
    material_property_names = 'solubility_in_phase'
    expression = 'solubility_in_phase * ${P} ^ ${solubility_order}'
    outputs = 'exodus'
  []
  [interface_jump]
    type = SolubilityRatioMaterial
    solubility_primary = solubility_Fe
    solubility_secondary = solubility_Li2O
    boundary = interface_Fe
    concentration_primary = concentration_Fe
    concentration_secondary = concentration_Li2O
  []
  [converter_to_regular]
    type = MaterialADConverter
    ad_props_in = 'diffusivity_Fe diffusivity_Li2O'
    reg_props_out = 'diffusivity_Fe_nonAD diffusivity_Li2O_nonAD'
    outputs = none
  []
[]

[Functions]
  [solubility_Fe_func]
    type = ParsedFunction
    expression = '${solubility_prefactor_Fe} * exp(- ${solubility_energy_Fe} / ${R} / ${T})'
  []
  [solubility_Li2O_func]
    type = ParsedFunction
    expression = '${solubility_prefactor_Li2O} * exp(- ${solubility_energy_Li2O} / ${R} / ${T})'
  []
  [concentration_in_BC_Fe_func]
    type = ParsedFunction
    symbol_names = 'solubility_Fe_func'
    symbol_values = 'solubility_Fe_func'
    expression = 'solubility_Fe_func  * ${P} ^ ${solubility_order}'
  []
  [concentration_in_BC_Li2O_func]
    type = ParsedFunction
    symbol_names = 'solubility_Li2O_func'
    symbol_values = 'solubility_Li2O_func'
    expression = 'solubility_Li2O_func  * ${P} ^ ${solubility_order}'
  []
[]

[Postprocessors]
  [diffusivity_Fe_theory]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Fe_nonAD
  []
  [diffusivity_Li2O_theory]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Li2O_nonAD
  []
  [Surface_tot]
    type = ElementIntegralMaterialProperty
    mat_prop = 1
  []
  [gold_solubility_ratio]
    type = ParsedPostprocessor
    pp_names = 'solubility_Fe solubility_Li2O'
    expression = 'solubility_Fe / solubility_Li2O'
  []
  [Fe_interface]
    type = SideAverageValue
    boundary = interface_Fe
    variable = concentration_Fe
  []
  [Li2O_interface]
    type = SideAverageValue
    boundary = interface_Li2O
    variable = concentration_Li2O
  []
  [variable_ratio]
    type = ParsedPostprocessor
    pp_names = 'Fe_interface Li2O_interface'
    expression = 'Fe_interface / Li2O_interface'
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
  file_base = ${output_file_name}
[]
