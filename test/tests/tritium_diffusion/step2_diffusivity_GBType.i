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
# type:                Steady-State
# Grain structure:     Bicrystal with heterogeneous diffusion (higher in GBs than within grains)
# BCs:                 Periodic for AEH, flux and fix for direct method
# System:              Ag in SiC with bulk and Gb diffusion from LLS
#
#
# Info:
# - Dimentional input file for the diffusion of a solute in a complex
#   polycrystal
# - Accounts for bulk irradiation-enhanced diffusivity
#
#
# Updates from previous file:
#
#
# Units
# length: nm
# time: s
# energy: --
# quantity: --

[Mesh]
  file = EBSD_grain_growth_2D_Poly_3_667_11_Wsize60_Simon_exodus.e-s002
[]

[GlobalParams]
  op_num = 6
  var_name_base = gr
[]

[UserObjects]
  [initial_grains]
    type = SolutionUserObject
    mesh = EBSD_grain_growth_2D_Poly_3_667_11_Wsize60_Simon_exodus.e-s002
    timestep = LATEST
  []
  [grain_tracker]
    type = GrainTracker
    threshold = 0.001
    connecting_threshold = 0.0008
    compute_var_to_feature_map = true
    execute_on = 'INITIAL'
    remap_grains = false
  []
[]

[Variables]
  [cx_AEH_an123] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
[]

[BCs]
  [Periodic]
    [all]
      auto_direction = 'x y'
      variable = 'cx_AEH_an123'
    []
  []
[]

[AuxVariables]
  [cy_AEH_an123] #composition used for the x-component of the AEH solve
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
  [bnds]
    order = FIRST
    family = LAGRANGE
  []
  [bnds_LAGB]
    order = FIRST
    family = LAGRANGE
  []
  [bnds_HAGB]
    order = FIRST
    family = LAGRANGE
  []
  [gb_type]
    order = CONSTANT
    family = MONOMIAL
  []
  [EBSD_grain]
    order = CONSTANT
    family = MONOMIAL
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
  [init_EBSD_grain]
    type = SolutionAux
    execute_on = INITIAL
    variable = EBSD_grain
    solution = initial_grains
    from_variable = ebsd_numbers
  []
  [gb_type]
    type = SolutionAux
    execute_on = 'INITIAL TIMESTEP_END'
    variable = gb_type
    solution = initial_grains
    from_variable = gb_type
  []
  [bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [bnds_LAGB]
    # Calculate the bnds for specific GB type
    type = SolutionAuxMisorientationBoundary
    variable = bnds_LAGB
    gb_type_order = 1
    solution = initial_grains
    from_variable = gb_type
    execute_on = 'INITIAL TIMESTEP_END'
  []
  [bnds_HAGB]
    # Calculate the bnds for specific GB type
    type = SolutionAuxMisorientationBoundary
    variable = bnds_HAGB
    gb_type_order = 2
    solution = initial_grains
    from_variable = gb_type
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

[Kernels]
  # an123
  [Diff_x_an123]
    type = MatDiffusion
    diffusivity = D_Scaling
    variable = cx_AEH_an123
    args = 'bnds'
  []
  [Diff_x_AEH_an123]
    type = HomogenizedHeatConduction
    diffusion_coefficient = D_Scaling
    variable = cx_AEH_an123
    component = 0
  []
[]

[Materials]
  #=========================================================== Generic Constants
  [consts]
    type = GenericConstantMaterial
    prop_names = 'R                 T    Flux     m_to_nm'
    prop_values = '8.31446261815324  1000 4.70e18  1e9'
    # unit         J.mol-1.K-1       K    n/m^2/s  -
  []
  [consts_original]
    type = GenericConstantMaterial
    prop_names = 'D_bulk      D_LAGB   D_HAGB'
    prop_values = '0.00701     1.742    4929.961'
    # unit         nm^2/s      nm^2/s   nm^2/s
  []
  [consts_expected]
    type = GenericConstantMaterial
    prop_names = 'Db          Dgbl     Dgbh'
    prop_values = '0.007       0.302    821.672'
    # unit         nm^2/s      nm^2/s   nm^2/s
    # outputs = exodus
  []
  #===================================================== Interpolation functions
  [hgb] # equal to 1 in grain boundaries, 0 elsewhere in grains.
    type = DerivativeParsedMaterial
    args = 'bnds'
    constant_names = 'bnds_middle width  tanh_cst_x2'
    constant_expressions = '0.6187       0.0448 2.1972245773362196'
    function = '1-0.5*(1.0+tanh(tanh_cst_x2*(bnds-bnds_middle)/width))'
    f_name = 'hgb'
    # outputs = exodus
  []
  [hgb_lagb] # equal to 1 in grain boundaries, 0 elsewhere in grains.
    type = DerivativeParsedMaterial
    args = 'bnds_LAGB'
    constant_names = 'bnds_middle width tanh_cst_x2'
    constant_expressions = '0.6187       0.0448 2.1972245773362196'
    function = '1-0.5*(1.0+tanh(tanh_cst_x2*(bnds_LAGB-bnds_middle)/width))'
    f_name = 'hgb_lagb'
    # outputs = exodus
  []
  [hgb_hagb] # equal to 1 in grain boundaries, 0 elsewhere in grains.
    type = DerivativeParsedMaterial
    args = 'bnds_HAGB'
    constant_names = 'bnds_middle width tanh_cst_x2'
    constant_expressions = '0.6187       0.0448 2.1972245773362196'
    function = '1-0.5*(1.0+tanh(tanh_cst_x2*(bnds_HAGB-bnds_middle)/width))'
    f_name = 'hgb_hagb'
    # outputs = exodus
  []
  [hgb_calc] # equal to 1 in grain boundaries, 0 elsewhere in grains.
    type = DerivativeParsedMaterial
    args = 'bnds_LAGB bnds_HAGB'
    constant_names = 'bnds_middle width tanh_cst_x2'
    constant_expressions = '0.6187       0.0448 2.1972245773362196'
    function = '1-0.5*(1.0+tanh(tanh_cst_x2*(bnds_LAGB-bnds_middle)/width)) +
                1-0.5*(1.0+tanh(tanh_cst_x2*(bnds_HAGB-bnds_middle)/width))'
    f_name = 'hgb_calc'
    # outputs = exodus
  []
  #====================================================== Diffusion coefficients
  [Grain_boundary_width] # size of grain boundaries in input polycrystal, as well as length scales for domain size
    type = GenericConstantMaterial
    prop_names = 'wGB_ref wGB  L   '
    prop_values = '1       60   9000'
    # unit         --           --  --  --
  []
  [Diffusion_coefficient_D_an123]
    type = DerivativeParsedMaterial
    f_name = 'D_Scaling'
    args = 'bnds'
    material_property_names = 'Db Dgbh Dgbl hgb_lagb(bnds_LAGB) hgb_hagb(bnds_HAGB) hgb(bnds)'
    function = '(1-hgb)*Db+hgb*hgb_lagb/(hgb_lagb+hgb_hagb)*Dgbl+hgb*hgb_hagb/(hgb_lagb+hgb_hagb)*Dgbh'
    # outputs = exodus
    derivative_order = 2
  []
[]

[Postprocessors]
  [D_x_AEH_an123] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH_an123 cy_AEH_an123'
    col = 0
    row = 0
    diffusion_coefficient = D_Scaling
    # execute_on = INITIAL
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [GB_surface]
    type = ElementIntegralMaterialProperty
    mat_prop = 'hgb'
    execute_on = 'INITIAL'
  []
  [Surface_tot]
    type = ElementIntegralMaterialProperty
    mat_prop = 1
  []
  [Ag_tot]
    type = ElementIntegralVariablePostprocessor
    variable = 'cx_AEH_an123'
    execute_on = 'INITIAL TIMESTEP_END'
  []
[]

# It converges faster if all the residuals are at the same magnitude
[Debug]
  show_var_residual_norms = true
[]

[Preconditioning]
  [SMP]
    type = SMP
    off_diag_row = 'cx_AEH_an123 '
    off_diag_column = 'cx_AEH_an123 '
  []
[]

[Executioner]
  type = Steady
  solve_type = 'NEWTON'
  # petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  # petsc_options_value = 'hypre boomeramg 31 0.7'

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
  file_base = 'AEH_Diffusion_Polycrystal_Ag_SiC_ref_output'
[]
