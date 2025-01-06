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

diffusivity_prefactor_Fe = '${units ${fparse exp(-5.93) * 1e-4} m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Fe = '${units ${fparse 81.73 * 1e3} J/mol}'
diffusivity_prefactor_Li2O = '${units ${fparse exp(-5.93) * 1e-4} m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Li2O = '${units ${fparse 81.73 * 1e3} J/mol}'

file_name = "gold/Polycrystal_Domain_1000_NumGrainHor_4_NumGrainVert_4.e-s002"

[Mesh]
  file = ${file_name}
[]

[GlobalParams]
  op_num = 12
  var_name_base = gr
[]

[UserObjects]
  [initial_grains]
    type = SolutionUserObject
    mesh = ${file_name}
    timestep = LATEST
  []
  [grain_tracker]
    type = GrainTracker
    threshold = 0.3
    connecting_threshold = 0.08
    compute_var_to_feature_map = true
    execute_on = 'INITIAL'
    remap_grains = false
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
  [gr8]
    order = FIRST
    family = LAGRANGE
  []
  [gr9]
    order = FIRST
    family = LAGRANGE
  []
  [gr10]
    order = FIRST
    family = LAGRANGE
  []
  [gr11]
    order = FIRST
    family = LAGRANGE
  []
[]

[AuxKernels]
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
  [init_gr8]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr8
    solution = initial_grains
    from_variable = gr8
  []
  [init_gr9]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr9
    solution = initial_grains
    from_variable = gr9
  []
  [init_gr10]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr10
    solution = initial_grains
    from_variable = gr10
  []
  [init_gr11]
    type = SolutionAux
    execute_on = INITIAL
    variable = gr11
    solution = initial_grains
    from_variable = gr11
  []
[]

[Kernels]
  [Diff_x]
    type = MatDiffusion
    diffusivity = diffusivity_Fe
    variable = cx_AEH
  []
  [Diff_x_AEH]
    type = HomogenizedHeatConduction
    diffusion_coefficient = diffusivity_Fe
    variable = cx_AEH
    component = 0
  []
  [Diff_y]
    type = MatDiffusion
    diffusivity = diffusivity_Fe
    variable = cy_AEH
  []
  [Diff_y_AEH]
    type = HomogenizedHeatConduction
    diffusion_coefficient = diffusivity_Fe
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
[]

[Postprocessors]
  [D_x_AEH] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH cy_AEH'
    col = 0
    row = 0
    diffusion_coefficient = diffusivity_Fe
    # execute_on = INITIAL
  []
  [D_y_AEH] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH cy_AEH'
    col = 1
    row = 1
    diffusion_coefficient = diffusivity_Fe
    # execute_on = INITIAL
  []
  [diffusivity_Fe]
    type = ElementAverageMaterialProperty
    mat_prop = diffusivity_Fe
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
