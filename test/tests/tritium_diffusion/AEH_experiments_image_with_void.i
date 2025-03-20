# MOOSE input file
# Based on AEH_experiments_image.i
# Added void phase transport capabilities

# Physical constants
R = '${units 8.31446261815324 J/mol/K}' # ideal gas constant based on number used in include/utils/PhysicalConstants.h
T = '${units 1000 K}'
P = '${units 1e5 Pa}'

# Material properties for solid phases
diffusivity_prefactor_Fe = '${units 1.9e-6 m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Fe = '${units 61300 J/mol}'
solubility_prefactor_Fe = '${units ${fparse 1.87e-6 / 3.016 * 55.845 * 4.04e28} at/m^3/Pa -> at/nm^3/Pa}' # at/m^3/Pa^0.5 -> at/nm^3/Pa^0.5
solubility_energy_Fe = '${units 8240 J/mol}'

diffusivity_prefactor_Li2O = '${units ${fparse exp(-5.93) * 1e-4} m^2/s -> nm^2/s}' # Tritium
diffusivity_energy_Li2O = '${units ${fparse 81.73 * 1e3} J/mol}'
solubility_prefactor_Li2O = '${units ${fparse 2.0568216e-05 * 4.04e28} at/m^3/Pa -> at/nm^3/Pa}' # at/m^3/Pa^0.5 -> at/nm^3/Pa^0.5
solubility_energy_Li2O = '${units ${fparse 1290 * R} J/mol}'

# Void phase properties
void_diffusivity = '${units 224767738.6 mum^2/s -> nm^2/s}' # Gas phase diffusion coefficient

figure_file_name = 'experiment_grayscale_figures/experiment_microstructure_3phases_Fe_018_phases.png'
output_file_name = 'AEH_experiment_microstructure_3phases_Fe_018_phases'

[Mesh]
  [image_mesh]
    type = ImageMeshGenerator
    dim = 2
    file = ${figure_file_name}
    scale_to_one = false
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
  [phase_void]
  []
  [image_Fe]
  []
  [image_Li2O]
  []
  [image_void]
  []
[]

[AuxKernels]
  [phase_Fe_auxkernel]
    type = FunctionAux
    function = phase_combination_Fe
    variable = phase_Fe
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [phase_Li2O_auxkernel]
    type = FunctionAux
    function = phase_combination_Li2O
    variable = phase_Li2O
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [phase_void_auxkernel]
    type = FunctionAux
    function = phase_combination_void
    variable = phase_void
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [image_Fe_auxkernel]
    type = FunctionAux
    function = image_Fe
    variable = image_Fe
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [image_Li2O_auxkernel]
    type = FunctionAux
    function = image_Li2O
    variable = image_Li2O
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [image_void_auxkernel]
    type = FunctionAux
    function = image_void
    variable = image_void
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Functions]
  [image_Fe]
    type = ImageFunction
    file = ${figure_file_name}
    threshold = 256  # High threshold for Fe (bright regions)
    lower_value = 1
    upper_value = 0
  []
  [image_Li2O]
    type = ImageFunction
    file = ${figure_file_name}
    threshold = 140  # Medium threshold for Li2O
    lower_value = 1
    upper_value = 0
  []
  [image_void]
    type = ImageFunction
    file = ${figure_file_name}
    threshold = 512   # Low threshold for void (dark regions)
    lower_value = 0
    upper_value = 1
  []
  [phase_combination_Fe]
    type = ParsedFunction
    expression = 'if(image_Fe > 0 & image_Li2O < 1, 1, 0)'
    symbol_names = 'image_Fe image_Li2O'
    symbol_values = 'image_Fe image_Li2O'
  []
  [phase_combination_Li2O]
    type = ParsedFunction
    expression = 'if(image_Li2O > 0, 1, 0)'
    symbol_names = 'image_Li2O'
    symbol_values = 'image_Li2O'
  []
  [phase_combination_void]
    type = ParsedFunction
    expression = 'if(image_void > 0, 1, 0)'
    symbol_names = 'image_void'
    symbol_values = 'image_void'
  []
[]

[Kernels]
  # Solid phase diffusion
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

[BCs]
  [Periodic]
    [all]
      auto_direction = 'x y'
      variable = 'cx_AEH cy_AEH'
    []
  []
[]

[Materials]
  # Solid phase properties
  [Diffusivity_Fe]
    type = ParsedMaterial
    property_name = 'diffusivity_Fe'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Fe}     ${diffusivity_energy_Fe}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusivity_Li2O]
    type = ParsedMaterial
    property_name = 'diffusivity_Li2O'
    constant_names = 'D0                              Ea'
    constant_expressions = '${diffusivity_prefactor_Li2O}     ${diffusivity_energy_Li2O}'
    expression = 'D0 * exp(-Ea / ${R} / ${T})'
  []
  [Diffusion_in_phase]
    type = ParsedMaterial
    property_name = 'diffusivity_in_phase'
    coupled_variables = 'phase_Fe phase_Li2O phase_void'
    material_property_names = 'diffusivity_Fe diffusivity_Li2O'
    expression = '(1-phase_void)*(phase_Fe * diffusivity_Fe + phase_Li2O * diffusivity_Li2O) + phase_void*${void_diffusivity}'
    outputs = 'exodus'
  []

  # # Void phase properties
  # [void_diffusivity]
  #   type = GenericConstantMaterial
  #   prop_names = 'void_diffusivity_mat'
  #   prop_values = '${void_diffusivity}'
  # []

  # Solubility properties
  [Solubility_Fe]
    type = ParsedMaterial
    property_name = 'solubility_Fe'
    constant_names = 'K0                              Es'
    constant_expressions = '${solubility_prefactor_Fe}     ${solubility_energy_Fe}'
    expression = 'K0 * exp(-Es / ${R} / ${T})'
  []
  [Solubility_Li2O]
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
    expression = '(phase_Fe * solubility_Fe + phase_Li2O * solubility_Li2O)'
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
  [phase_void_field]
    type = ADParsedMaterial
    property_name = phase_void_field
    coupled_variables = 'phase_void'
    expression = 'phase_void'
    outputs = exodus
  []
[]

[Postprocessors]
  [D_x_AEH]
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH cy_AEH'
    col = 0
    row = 0
    diffusion_coefficient = diffusivity_in_phase
  []
  [D_y_AEH]
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH cy_AEH'
    col = 1
    row = 1
    diffusion_coefficient = diffusivity_in_phase
  []
  [effective_solubility]
    type = ElementAverageMaterialProperty
    mat_prop = solubility_in_phase
  []
  [concentration_bc_test]
    type = ElementAverageMaterialProperty
    mat_prop = concentration_in_BC
  []
  [Fe_phase_area]
    type = ADElementIntegralMaterialProperty
    mat_prop = 'phase_Fe_field'
    execute_on = 'initial timestep_end'
  []
  [Li2O_phase_area]
    type = ADElementIntegralMaterialProperty
    mat_prop = 'phase_Li2O_field'
    execute_on = 'initial timestep_end'
  []
  [void_phase_area]
    type = ADElementIntegralMaterialProperty
    mat_prop = 'phase_void_field'
    execute_on = 'initial timestep_end'
  []
  [phase_fractions]
    type = ParsedPostprocessor
    pp_names = 'Fe_phase_area Li2O_phase_area void_phase_area'
    expression = 'Fe_phase_area / (Fe_phase_area + Li2O_phase_area + void_phase_area)'
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

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
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
