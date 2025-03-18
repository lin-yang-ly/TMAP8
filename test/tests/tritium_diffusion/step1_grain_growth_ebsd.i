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

# This simulation predicts GB migration of a 2D copper polycrystal with 15 grains
# Mesh adaptivity (new system) and time step adaptivity are used
# An AuxVariable is used to calculate the grain boundary locations
# Postprocessors are used to record time step and the number of grains
# We are not using the GrainTracker in this example so the number
# of order paramaters must match the number of grains.

# width = 10
# input_file_name = 'EBSD_files/experiment_mario_microstructure_Fe_050_ebsd.txt'
# output_file_name = 'Polycrystal_experiment_mario_PF050_test'
width = 2
input_file_name = 'EBSD_files/experiment_microstructure_Fe_050_ebsd.txt'
output_file_name = 'Polycrystal_experiment_PF050'
bound_value_upper_limit = 1.0001
bound_value_lower_limit = 1e-10
dt_initial = 0.1
simulation_time = 1

[Mesh]
  [ebsd_mesh]
    type = EBSDMeshGenerator
    filename = ${input_file_name}
  []
[]

[GlobalParams]
  # Parameters used by several kernels that are defined globally to simplify input file
  op_num = 2 # Number of grains
  var_name_base = gr # Base name of grains
[]

[UserObjects]
  [ebsd_reader]
    type = EBSDReader
  []
  [ebsd]
    type = PolycrystalEBSD
    coloring_algorithm = bt
    ebsd_reader = ebsd_reader
    enable_var_coloring = true
    # output_adjacency_matrix = true
  []
  [grain_tracker]
    type = GrainTracker
    threshold = 0.3
    compute_var_to_feature_map = true
    compute_halo_maps = false # For not displaying HALO fields
    remap_grains = false
    polycrystal_ic_uo = ebsd
    execute_on = 'initial timestep_end'
  []
[]

[Bounds]
  [gr0_upper_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = gr0
    bound_type = upper
    bound_value = ${bound_value_upper_limit}
  []
  [gr1_upper_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = gr1
    bound_type = upper
    bound_value = ${bound_value_upper_limit}
  []
  # [gr2_upper_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr2
  #   bound_type = upper
  #   bound_value = ${bound_value_upper_limit}
  # []
  # [gr3_upper_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr3
  #   bound_type = upper
  #   bound_value = ${bound_value_upper_limit}
  # []
  # [gr4_upper_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr4
  #   bound_type = upper
  #   bound_value = ${bound_value_upper_limit}
  # []
  # [gr5_upper_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr5
  #   bound_type = upper
  #   bound_value = ${bound_value_upper_limit}
  # []
  [gr0_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = gr0
    bound_type = lower
    bound_value = ${bound_value_lower_limit}
  []
  [gr1_lower_bound]
    type = ConstantBounds
    variable = bounds_dummy
    bounded_variable = gr1
    bound_type = lower
    bound_value = ${bound_value_lower_limit}
  []
  # [gr2_lower_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr2
  #   bound_type = lower
  #   bound_value = ${bound_value_lower_limit}
  # []
  # [gr3_lower_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr3
  #   bound_type = lower
  #   bound_value = ${bound_value_lower_limit}
  # []
  # [gr4_lower_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr4
  #   bound_type = lower
  #   bound_value = ${bound_value_lower_limit}
  # []
  # [gr5_lower_bound]
  #   type = ConstantBounds
  #   variable = bounds_dummy
  #   bounded_variable = gr5
  #   bound_type = lower
  #   bound_value = ${bound_value_lower_limit}
  # []
[]

[ICs]
  [PolycrystalICs]
    [PolycrystalColoringIC]
      polycrystal_ic_uo = ebsd
    []
  []
[]

[Variables]
  # Variable block, where all variables in the simulation are declared
  [PolycrystalVariables]
    # Custom action that created all of the grain variables and sets their initial condition
  []
[]

[AuxVariables]
  # Dependent variables
  [bnds]
    # Variable used to visualize the grain boundaries in the simulation
  []
  [unique_grains]
    order = CONSTANT
    family = MONOMIAL
  []
  [aphi1]
    order = CONSTANT
    family = MONOMIAL
  []
  [bPhi]
    order = CONSTANT
    family = MONOMIAL
  []
  [cphi2]
    order = CONSTANT
    family = MONOMIAL
  []
  [ebsd_numbers]
    order = CONSTANT
    family = MONOMIAL
  []
  [phase_numbers]
    order = CONSTANT
    family = MONOMIAL
  []
  [bounds_dummy]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  # Kernel block, where the kernels defining the residual equations are set up.
  [PolycrystalKernel]
    # Custom action creating all necessary kernels for grain growth.  All input parameters are up in GlobalParams
  []
[]

[AuxKernels]
  # AuxKernel block, defining the equations used to calculate the auxvars
  [bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    execute_on = 'initial timestep_end'
  []

  # generate the unique ID from grain_tracker
  [unique_grains]
    type = FeatureFloodCountAux
    variable = unique_grains
    execute_on = 'initial timestep_end'
    flood_counter = grain_tracker
    field_display = UNIQUE_REGION
  []
  # The phi will output the Euler angle from EBSD data, and the data structure
  # will change with the guide from grain_tracker
  [aphi1]
    type = OutputEulerAngles
    variable = aphi1
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'phi1'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [bPhi]
    type = OutputEulerAngles
    variable = bPhi
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'Phi'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [cphi2]
    type = OutputEulerAngles
    variable = cphi2
    euler_angle_provider = ebsd_reader
    grain_tracker = grain_tracker
    output_euler_angle = 'phi2'
    execute_on = 'INITIAL TIMESTEP_END'
  []

  # Import the unique grain ID from ebsd data, and the data structure
  # will change with the guide from grain_tracker
  [ebsd_numbers]
    type = EBSDReaderAvgDataAux
    data_name = feature_id
    ebsd_reader = ebsd_reader
    grain_tracker = grain_tracker
    variable = ebsd_numbers
    execute_on = 'initial timestep_end'
  []
  [phase_numbers]
    type = EBSDReaderAvgDataAux
    data_name = phase
    ebsd_reader = ebsd_reader
    grain_tracker = grain_tracker
    variable = phase_numbers
    execute_on = 'initial timestep_end'
  []
[]

[BCs]
  # Boundary Condition block
  [Periodic]
    [top_bottom]
      auto_direction = 'x y' # Makes problem periodic in the x and y directions
    []
  []
[]

[Modules]
  [PhaseField]
    [EulerAngles2RGB]
      crystal_structure = cubic
      euler_angle_provider = ebsd_reader
      grain_tracker = grain_tracker
    []
  []
[]

[Materials]
  [CuGrGr]
    # Material properties
    type = GBEvolution # Quantitative material properties for copper grain growth.  Dimensions are nm and ns
    GBmob0 = 2.5e-6 # Mobility prefactor for Cu from Schonfelder1997
    GBenergy = 0.708 # GB energy for Cu from Schonfelder1997
    Q = 0.23 # Activation energy for grain growth from Schonfelder 1997
    T = 450 # Constant temperature of the simulation (for mobility calculation)
    wGB = ${width} #5 # Width of the diffuse GB
  []
  # [GB_type]
  #   # The new developed Miso Bnds Aux Kernel
  #   type = ComputeGBMisorientationType
  #   ebsd_reader = ebsd_reader
  #   grain_tracker = grain_tracker
  #   output_properties = 'gb_type'
  #   outputs = exodus
  # []
  [GB_matrix]
    type = ADParsedMaterial
    property_name = GB_matrix
    coupled_variables = 'bnds'
    expression = 'if(bnds < 0.9, 1, 0)'
    outputs = exodus
  []
[]

[Postprocessors]
  # Scalar postprocessors
  [dt]
    # Outputs the current time step
    type = TimestepSize
  []
  [n_elements]
    type = NumElements
    execute_on = 'initial timestep_end'
  []
  [n_nodes]
    type = NumNodes
    execute_on = 'initial timestep_end'
  []
  [DOFs]
    type = NumDOFs
  []
  [gb_area]
    type = ADElementIntegralMaterialProperty
    mat_prop = 'GB_matrix'
    execute_on = 'initial timestep_end'
  []
  [Surface_tot]
    type = ElementIntegralMaterialProperty
    mat_prop = 1
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
  type = Transient # Type of executioner, here it is transient with an adaptive time step
  scheme = bdf2 # Type of time integration (2nd order backward euler), defaults to 1st order backward euler

  #Preconditioned JFNK (default)
  # solve_type = 'PJFNK'

  # petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold'
  # petsc_options_value = '  hypre    boomeramg                   0.7'

  solve_type = 'NEWTON'

  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -snes_type'
  petsc_options_value = 'lu vinewtonrsls'

  l_max_its = 30 # Max number of linear iterations
  l_tol = 1e-4 # Relative tolerance for linear solves
  nl_max_its = 40 # Max number of nonlinear iterations
  nl_abs_tol = 1e-11 # Relative tolerance for nonlienar solves
  nl_rel_tol = 1e-10 # Absolute tolerance for nonlienar solves

  [TimeStepper]
    type = IterationAdaptiveDT
    cutback_factor = 0.9
    dt = ${dt_initial}
    growth_factor = 1.1
    optimal_iterations = 7
  []
  # [Adaptivity]
  #   initial_adaptivity = 1
  #   refine_fraction = 1.0
  #   coarsen_fraction = 0.0
  #   max_h_level = 1
  # []

  start_time = 0.0
  end_time = ${simulation_time}
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
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]
