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

diffusivity_prefactor_Fe = '${units 1.9e-6 m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Fe = '${units 61300 J/mol}'
diffusivity_prefactor_Li2O = '${units ${fparse exp(-5.93) * 1e-4} m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Li2O = '${units ${fparse 81.73 * 1e3} J/mol}'

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
  [Diffusion_coefficient_diffusivity_Fe] # bulk diffusivity contribution
    type = ParsedMaterial
    f_name = 'diffusivity_Fe'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Fe}     ${diffusivity_energy_Fe}'
    function = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusion_coefficient_diffusivity_Li2O] # bulk diffusivity contribution
    type = ParsedMaterial
    f_name = 'diffusivity_Li2O'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Li2O}     ${diffusivity_energy_Li2O}'
    function = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusion_in_phase]
    type = ParsedMaterial
    f_name = 'diffusivity_in_phase'
    args = 'phase_numbers'
    material_property_names = 'diffusivity_Fe diffusivity_Li2O'
    function = '(2 - phase_numbers) * diffusivity_Fe + (phase_numbers - 1) * diffusivity_Li2O'
  []
  # [Diffusion_in_phase]
  #   type = ParsedMaterial
  #   f_name = 'diffusivity_in_phase'
  #   material_property_names = 'diffusivity_Fe diffusivity_Li2O'
  #   function = 'diffusivity_Li2O'
  #   outputs = exodus
  # []
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

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  l_max_its = 50
  nl_max_its = 50
  l_tol = 1e-04
  l_abs_tol = 1e-50
  nl_abs_tol = 1e-20
  nl_rel_tol = 1e-10
[]

[Outputs]
  exodus = false
  perf_graph = true
  csv = true
  file_base = 'AEH_Diffusion_Polycrystal_Tritium_output'
[]
