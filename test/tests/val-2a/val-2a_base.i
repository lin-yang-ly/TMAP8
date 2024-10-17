high_dt_max = 100
low_dt_max = 1
# Temperature = '${units 703 K}'
simulation_time = '${units 2e4 s}'
diffusivity_D = '${units 3e-10 m^2/s -> mum^2/s}'
# dissociation_parameter_enclos2 = '${units 1.7918e15 at/m^2/s/Pa -> at/mum^2/s/Pa}' # d2/m^2/s/pa
recombination_parameter_enclos2 = '${units 2e-31 m^4/at/s -> mum^4/at/s}'    # m^4/atom/s
pressure_high = '${units 4e-5 Pa}'
pressure_low =  '${units 9e-6 Pa}'
# pressure_right = '${units 2e-6 Pa}'
flux_high = '${units 4.9e19 at/m^2/s -> at/mum^2/s}'
flux_low =  '${units 0      at/mum^2/s}'
dissociation_coefficient_parameter_enclos1 = '${units 8.959e18 at/m^2/s/Pa -> at/mum^2/s/Pa}'  # d2/m^2/s/pa
# Data in TMAP4
recombination_coefficient_parameter_enclos1_TMAP4 = '${units 1e-27 m^4/at/s -> mum^4/at/s}'    # m^4/atom/s
# Data in TMAP7
recombination_coefficient_parameter_enclos1_TMAP7 = '${units 7e-27 m^4/at/s -> mum^4/at/s}'    # m^4/atom/s


[Variables]
  [concentration]
    order = FIRST
    family = LAGRANGE
  []
[]

[Kernels]
  [diffusion]
    type = ADMatDiffusion
    variable = concentration
    diffusivity = ${diffusivity_D}
  []
  [time_diffusion]
    type = ADTimeDerivative
    variable = concentration
  []
  [source]
    type = ADBodyForce
    variable = concentration
    function = concentration_source_norm_func
  []
[]

[AuxVariables]
  [pressure_left]
  []
  [concentration_source]
  []
  [recombination_TMAP4]
  []
  [recombination_TMAP7]
  []
[]

[AuxKernels]
  [pressure_aux]
    type = FunctionAux
    variable = pressure_left
    function = pressure_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [concentration_source_aux]
    type = FunctionAux
    variable = concentration_source
    function = concentration_source_norm_func
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [recombination_aux_TMAP4]
    type = FunctionAux
    variable = recombination_TMAP4
    function = '${recombination_coefficient_parameter_enclos1_TMAP4}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [recombination_aux_TMAP7]
    type = FunctionAux
    variable = recombination_TMAP7
    function = '${recombination_coefficient_parameter_enclos1_TMAP7}'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[BCs]
  [./left]
    type = MatNeumannBC
    variable = concentration
    boundary = left
    value = 1
    boundary_material = flux_on_left
  [../]
  [./right]
    type = MatNeumannBC
    variable = concentration
    boundary = right
    value = 1
    boundary_material = flux_on_right
  [../]
[]

[Materials]
  [flux_on_left]
    type = DerivativeParsedMaterial
    coupled_variables = 'concentration'
    property_name = 'flux_on_left'
    functor_names = 'Kr_left_func'
    functor_symbols = 'Kr_left_func'
    expression = '- 2 * Kr_left_func * concentration ^ 2 / ${diffusivity_D}'
  []
  [flux_on_right]
    type = DerivativeParsedMaterial
    coupled_variables = 'concentration'
    property_name = 'flux_on_right'
    expression = '- 2 * ${recombination_parameter_enclos2} * concentration ^ 2 / ${diffusivity_D}'
  []
[]

[Postprocessors]
  [flux_surface_left]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = '${diffusivity_D}'
    boundary = 'left'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_left]
    type = ScalePostprocessor
    scaling_factor = '${units 1 m^2 -> mum^2}'
    value = flux_surface_left
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [flux_surface_right]
    type = SideDiffusiveFluxIntegral
    variable = concentration
    diffusivity = '${diffusivity_D}'
    boundary = 'right'
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [scaled_flux_surface_right]
    type = ScalePostprocessor
    scaling_factor = '${units 1 m^2 -> mum^2}'
    value = flux_surface_right
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = 'console csv exodus'
  []
  [max_time_step_size]
    type = FunctionValuePostprocessor
    function = max_dt_size_func
    execute_on = 'initial nonlinear linear timestep_end'
    outputs = none
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]


[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  end_time = ${simulation_time}
  automatic_scaling = true
  nl_abs_tol = 1e-12
  nl_rel_tol = 1e-6
  # nl_max_its = 9
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e2
    optimal_iterations = 12
    growth_factor = 1.1
    cutback_factor = 0.9
    timestep_limiting_postprocessor = max_time_step_size
  []
[]

# [Executioner]
#   type = Transient
#   scheme = bdf2
#   solve_type = NEWTON
#   petsc_options_iname = '-pc_type'
#   petsc_options_value = 'lu'
#   nl_rel_tol = 1e-8
#   nl_abs_tol = 1e-5
#   l_tol = 1e-4
#   end_time = ${simulation_time}
#   automatic_scaling = true
#   line_search = 'none'

#   [TimeStepper]
#     type = IterationAdaptiveDT
#     dt = 1
#     optimal_iterations = 4
#     growth_factor = 1.1
#     cutback_factor = 0.9
#     timestep_limiting_postprocessor = max_time_step_size
#   []
# []
