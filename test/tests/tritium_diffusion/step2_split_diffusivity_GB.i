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
    threshold = 0.3
    connecting_threshold = 0.08
    compute_var_to_feature_map = true
    execute_on = 'INITIAL'
    remap_grains = false
  []
[]

[Variables]
  [cx_AEH_an1x1y] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
  # [cy_AEH_an1x1y] #composition used for the x-component of the AEH solve
  #   initial_condition = 0.5
  # []
  [cx_AEH_an1x2a] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
  # [cy_AEH_an1x2a] #composition used for the x-component of the AEH solve
  #   initial_condition = 0.5
  # []
  [cx_AEH_an1y2a] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
  # [cy_AEH_an1y2a] #composition used for the x-component of the AEH solve
  #   initial_condition = 0.5
  # []
  [cx_AEH_an1x2b] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
  # [cy_AEH_an1x2b] #composition used for the x-component of the AEH solve
  #   initial_condition = 0.5
  # []
  [cx_AEH_an1y2b] #composition used for the x-component of the AEH solve
    initial_condition = 0.5
  []
  # [cy_AEH_an1y2b] #composition used for the x-component of the AEH solve
  #   initial_condition = 0.5
  # []
[]

[BCs]
  [Periodic]
    [all]
      auto_direction = 'x y'
      variable = 'cx_AEH_an1x1y cx_AEH_an1x2a cx_AEH_an1y2a cx_AEH_an1x2b cx_AEH_an1y2b'
      # variable = 'cx_AEH_an1x1y cy_AEH_an1x1y cx_AEH_an1x2a cy_AEH_an1x2a cx_AEH_an1y2a cy_AEH_an1y2a cx_AEH_an1x2b cy_AEH_an1x2b cx_AEH_an1y2b cy_AEH_an1y2b'
    []
  []
[]

[AuxVariables]
  [cy_AEH_an1x1y] #composition used for the x-component of the AEH solve
    order = FIRST
    family = LAGRANGE
  []
  [cy_AEH_an1x2a] #composition used for the x-component of the AEH solve
    order = FIRST
    family = LAGRANGE
  []
  [cy_AEH_an1y2a] #composition used for the x-component of the AEH solve
    order = FIRST
    family = LAGRANGE
  []
  [cy_AEH_an1x2b] #composition used for the x-component of the AEH solve
    order = FIRST
    family = LAGRANGE
  []
  [cy_AEH_an1y2b] #composition used for the x-component of the AEH solve
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
  [bnds_aux]
    # AuxKernel that calculates the GB term
    type = BndsCalcAux
    variable = bnds
    execute_on = INITIAL
  []
[]

[Kernels]
  # an1x1y
  [Diff_x_an1x1y]
    type = MatDiffusion
    diffusivity = D_an1x1y
    variable = cx_AEH_an1x1y
    args = 'bnds'
  []
  # [Diff_y_an1x1y]
  #   type = MatDiffusion
  #   diffusivity = D_an1x1y
  #   variable = cy_AEH_an1x1y
  #   args = 'bnds'
  # []
  [Diff_x_AEH_an1x1y]
    type = HomogenizedHeatConduction
    diffusion_coefficient = D_an1x1y
    variable = cx_AEH_an1x1y
    component = 0
  []
  # [Diff_y_AEH_an1x1y]
  #   type = HomogenizedHeatConduction
  #   diffusion_coefficient = D_an1x1y
  #   variable = cy_AEH_an1x1y
  #   component = 0
  # []
  # an1x2a
  [Diff_x_an1x2a]
    type = MatDiffusion
    diffusivity = D_an1x2a
    variable = cx_AEH_an1x2a
    args = 'bnds'
  []
  # [Diff_y_an1x2a]
  #   type = MatDiffusion
  #   diffusivity = D_an1x2a
  #   variable = cy_AEH_an1x2a
  #   args = 'bnds'
  # []
  [Diff_x_AEH_an1x2a]
    type = HomogenizedHeatConduction
    diffusion_coefficient = D_an1x2a
    variable = cx_AEH_an1x2a
    component = 0
  []
  # [Diff_y_AEH_an1x2a]
  #   type = HomogenizedHeatConduction
  #   diffusion_coefficient = D_an1x2a
  #   variable = cy_AEH_an1x2a
  #   component = 0
  # []
  # an1y2a
  [Diff_x_an1y2a]
    type = MatDiffusion
    diffusivity = D_an1y2a
    variable = cx_AEH_an1y2a
    args = 'bnds'
  []
  # [Diff_y_an1y2a]
  #   type = MatDiffusion
  #   diffusivity = D_an1y2a
  #   variable = cy_AEH_an1y2a
  #   args = 'bnds'
  # []
  [Diff_x_AEH_an1y2a]
    type = HomogenizedHeatConduction
    diffusion_coefficient = D_an1y2a
    variable = cx_AEH_an1y2a
    component = 0
  []
  # [Diff_y_AEH_an1y2a]
  #   type = HomogenizedHeatConduction
  #   diffusion_coefficient = D_an1y2a
  #   variable = cy_AEH_an1y2a
  #   component = 0
  # []
  # an1x2b
  [Diff_x_an1x2b]
    type = MatDiffusion
    diffusivity = D_an1x2b
    variable = cx_AEH_an1x2b
    args = 'bnds'
  []
  # [Diff_y_an1x2b]
  #   type = MatDiffusion
  #   diffusivity = D_an1x2b
  #   variable = cy_AEH_an1x2b
  #   args = 'bnds'
  # []
  [Diff_x_AEH_an1x2b]
    type = HomogenizedHeatConduction
    diffusion_coefficient = D_an1x2b
    variable = cx_AEH_an1x2b
    component = 0
  []
  # [Diff_y_AEH_an1x2b]
  #   type = HomogenizedHeatConduction
  #   diffusion_coefficient = D_an1x2b
  #   variable = cy_AEH_an1x2b
  #   component = 0
  # []
  # an1y2b
  [Diff_x_an1y2b]
    type = MatDiffusion
    diffusivity = D_an1y2b
    variable = cx_AEH_an1y2b
    args = 'bnds'
  []
  # [Diff_y_an1y2b]
  #   type = MatDiffusion
  #   diffusivity = D_an1y2b
  #   variable = cy_AEH_an1y2b
  #   args = 'bnds'
  # []
  [Diff_x_AEH_an1y2b]
    type = HomogenizedHeatConduction
    diffusion_coefficient = D_an1y2b
    variable = cx_AEH_an1y2b
    component = 0
  []
  # [Diff_y_AEH_an1y2b]
  #   type = HomogenizedHeatConduction
  #   diffusion_coefficient = D_an1y2b
  #   variable = cy_AEH_an1y2b
  #   component = 0
  # []
[]

[Materials]
  #=========================================================== Generic Constants
  [consts]
    type = GenericConstantMaterial
    prop_names = 'R                 T    Flux     m_to_nm'
    prop_values = '8.31446261815324  1000 4.70e18  1e9'
    # unit         J.mol-1.K-1       K    n/m^2/s  -
  []
  #===================================================== Interpolation functions
  [hgb] # equal to 1 in grain boundaries, 0 elsewhere in grains.
    type = DerivativeParsedMaterial
    args = 'bnds'
    constant_names = 'bnds_middle width  tanh_cst_x2'
    # constant_expressions = '0.625       0.0795 2.1972245773362196'
    constant_expressions = '0.6187       0.0448 2.1972245773362196'
    function = '1-0.5*(1.0+tanh(tanh_cst_x2*(bnds-bnds_middle)/width))'
    f_name = 'hgb'
    # outputs = exodus
  []
  #====================================================== Diffusion coefficients
  #====================== Diffusion coefficients - Basic values and coefficients
  [Diffusion_coefficient_Db_thermal] # bulk thermal contribution
    type = ParsedMaterial
    f_name = 'Db_th'
    constant_names = 'D0           Ea'
    constant_expressions = '2.4e+14     459000'
    #nm^2/s        J/mol
    material_property_names = 'R T'
    function = 'D0*exp(-Ea/R/T)'
    # outputs = exodus
  []
  [Diffusion_coefficient_Db_irr] # bulk irradiation-enhanced contribution
    type = ParsedMaterial
    f_name = 'Db_irr'
    constant_names = 'a         b      c     d      F_0'
    constant_expressions = '1.056e-30 0.9177 3788  -31216 1'
    #m^2/s     -      J/mol J/mol  n/m^2/s
    material_property_names = 'R T Flux m_to_nm'
    function = 'm_to_nm^2 * a*(Flux/F_0)^b * exp(-(c*plog(Flux,1e-6) + d)/R/T)'
    # outputs = exodus
  []
  [Diffusion_coefficient_Db] # bulk total
    type = ParsedMaterial
    f_name = 'Db'
    material_property_names = 'Db_th Db_irr'
    function = 'Db_th + Db_irr'
    # outputs = exodus
  []
  [Diffusion_coefficient_Dgb] # grain boundary with Low angle / High angle
    type = ParsedMaterial
    f_name = 'Dgb'
    constant_names = 'D0           Ea'
    constant_expressions = '9.3132e+7     80722.99'
    #nm^2/s        J/mol
    material_property_names = 'R T'
    function = 'D0*exp(-Ea/R/T)'
    # outputs = exodus
  []
  [Grain_boundary_width] # size of grain boundaries in input polycrystal, as well as length scales for domain size
    type = GenericConstantMaterial
    prop_names = 'wGB_ref wGB  L   '
    prop_values = '1       60   9000'
    # unit         --           --  --  --
  []
  # [./Diffusion_coefficient_Dglobal] # global diffusion
  #   type = DerivativeParsedMaterial
  #   f_name = 'D_global'
  #   args = 'bnds'
  #   material_property_names = 'hgb(bnds) Db Dgb'
  #   function = '(1-hgb)*Db+hgb*Dgb'
  #   outputs = exodus
  # [../]
  #============================================ Effective Diffusion coefficients
  [Effective_diffusion_1x_theoritical] # Based on Analytical derivation - Effective diffusion in case i (GB in parallel)
    type = ParsedMaterial
    f_name = 'Deff1x'
    material_property_names = 'L wGB_ref Db Dgb'
    function = 'Db+2*wGB_ref/L*(Dgb-Db)'
  []
  [Effective_diffusion_1y_theoritical] # Based on Analytical derivation - Effective diffusion in case ii (GB in series)
    type = ParsedMaterial
    f_name = 'Deff1y'
    material_property_names = 'L wGB_ref Db Dgb'
    function = 'Db*Dgb/((1-2*wGB_ref/L)*Dgb + 2*wGB_ref/L*Db)'
  []
  [Effective_diffusion_21_theoritical] # Based on Analytical derivation - Effective diffusion in case iii (GB in + configuration, middle vertical GB in parallel with 2 grains and horizontal GB)
    type = ParsedMaterial
    f_name = 'Deff21'
    material_property_names = 'L wGB_ref Db Dgb'
    function = '(1-wGB_ref/L)*Db*Dgb/((1-wGB_ref/L)*Dgb + wGB_ref/L*Db) + wGB_ref/L*Dgb'
  []
  [Effective_diffusion_22_theoritical] # Based on Analytical derivation - Effective diffusion in case iii (GB in + configuration, 2 grains with vertical GB * 2 in series with vertical GB)
    type = ParsedMaterial
    f_name = 'Deff22'
    material_property_names = 'L wGB_ref Db Dgb'
    function = 'Dgb*L*(Db*L - Db*wGB_ref + Dgb*wGB_ref)/(Db*L*wGB_ref - Db*wGB_ref^2 + Dgb*L^2 - Dgb*L*wGB_ref + Dgb*wGB_ref^2)' # Yes, it is the same than what is in the python script.
  []
  #============================================ Corrected Diffusion coefficients
  #========================================================= Analytical 1 - 1x1y
  [Equation_coefficient_Db_corrected_a_an1x1y] # coefficient a in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'a_Db_an1x1y'
    material_property_names = 'L wGB'
    function = '1-L/2/wGB'
  []
  [Equation_coefficient_Db_corrected_b_an1x1y] # coefficient b in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'b_Db_an1x1y'
    material_property_names = 'L wGB Deff1x Deff1y'
    function = 'L/2/wGB*Deff1x-(2-L/2/wGB)*Deff1y'
  []
  [Equation_coefficient_Db_corrected_c_an1x1y] # coefficient c in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'c_Db_an1x1y'
    material_property_names = 'L wGB Deff1x Deff1y'
    function = 'Deff1x*Deff1y*(1-L/2/wGB)'
  []
  [Diffusion_coefficient_Db_corrected_scale_up_an1x1y] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dbc_an1x1y'
    material_property_names = 'a_Db_an1x1y b_Db_an1x1y c_Db_an1x1y'
    function = '(-b_Db_an1x1y+sqrt(b_Db_an1x1y*b_Db_an1x1y-4*a_Db_an1x1y*c_Db_an1x1y))/2/a_Db_an1x1y'
  []
  [Diffusion_coefficient_Dgb_corrected_scale_up_an1x1y] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dgbc_an1x1y'
    material_property_names = 'L wGB Dbc_an1x1y Deff1x' #The obvious dependence on Dgb is included in Deff1x
    function = '(1-L/2/wGB)*Dbc_an1x1y+L/2/wGB*Deff1x'
  []
  [Diffusion_coefficient_D_an1x1y]
    type = DerivativeParsedMaterial
    f_name = 'D_an1x1y'
    args = 'bnds'
    material_property_names = 'Dbc_an1x1y Dgbc_an1x1y hgb(bnds)'
    function = '(1-hgb)*Dbc_an1x1y+hgb*Dgbc_an1x1y'
    # outputs = exodus
    derivative_order = 2
  []
  #========================================================= Analytical 2 - 1x2a
  [Equation_coefficient_Db_corrected_a_an1x2a] # coefficient a in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'a_Db_an1x2a'
    material_property_names = 'L wGB'
    function = '-1/4 - wGB/2/L + L/4/wGB'
  []
  [Equation_coefficient_Db_corrected_b_an1x2a] # coefficient b in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'b_Db_an1x2a'
    material_property_names = 'L wGB Deff1x Deff21'
    function = '(wGB/2/L-1)*Deff1x + (3/2-L/2/wGB)*Deff21'
  []
  [Equation_coefficient_Db_corrected_c_an1x2a] # coefficient c in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'c_Db_an1x2a'
    material_property_names = 'L wGB Deff1x Deff21'
    function = '(L/2/wGB-1/2) * Deff1x * (Deff21 - 1/2*Deff1x)'
  []
  [Diffusion_coefficient_Db_corrected_scale_up_an1x2a] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dbc_an1x2a'
    material_property_names = 'a_Db_an1x2a b_Db_an1x2a c_Db_an1x2a'
    function = '(-b_Db_an1x2a-sqrt(b_Db_an1x2a*b_Db_an1x2a-4*a_Db_an1x2a*c_Db_an1x2a))/2/a_Db_an1x2a'
  []
  [Diffusion_coefficient_Dgb_corrected_scale_up_an1x2a] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dgbc_an1x2a'
    material_property_names = 'L wGB Dbc_an1x2a Deff1x' #The obvious dependence on Dgb is included in Deff1x
    function = '(1-L/2/wGB)*Dbc_an1x2a + L/2/wGB*Deff1x'
  []
  [Diffusion_coefficient_D_an1x2a]
    type = DerivativeParsedMaterial
    f_name = 'D_an1x2a'
    args = 'bnds'
    material_property_names = 'Dbc_an1x2a Dgbc_an1x2a hgb(bnds)'
    function = '(1-hgb)*Dbc_an1x2a+hgb*Dgbc_an1x2a'
    # outputs = exodus
    derivative_order = 2
  []
  #========================================================= Analytical 3 - 1y2a
  [Equation_coefficient_DGB_corrected_a_an1y2a] # coefficient a in quadratic equation for corrected DGB
    type = ParsedMaterial
    f_name = 'a_DGB_an1y2a'
    material_property_names = 'L wGB'
    function = 'wGB/L * (1-wGB/L)'
  []
  [Equation_coefficient_DGB_corrected_b_an1y2a] # coefficient b in quadratic equation for corrected DGB
    type = ParsedMaterial
    f_name = 'b_DGB_an1y2a'
    material_property_names = 'L wGB Deff1y Deff21'
    function = '(1-3*wGB/L+wGB*wGB/L/L) * Deff1y + (wGB/L-1) * Deff21'
  []
  [Equation_coefficient_DGB_corrected_c_an1y2a] # coefficient c in quadratic equation for corrected DGB
    type = ParsedMaterial
    f_name = 'c_DGB_an1y2a'
    material_property_names = 'L wGB Deff1y Deff21'
    function = 'wGB/L * Deff1y * Deff21'
  []
  [Diffusion_coefficient_DGB_corrected_scale_up_an1y2a] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dgbc_an1y2a'
    material_property_names = 'a_DGB_an1y2a b_DGB_an1y2a c_DGB_an1y2a'
    function = '(-b_DGB_an1y2a+sqrt(b_DGB_an1y2a*b_DGB_an1y2a-4*a_DGB_an1y2a*c_DGB_an1y2a))/2/a_DGB_an1y2a'
  []
  [Diffusion_coefficient_Db_corrected_scale_up_an1y2a] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dbc_an1y2a'
    material_property_names = 'L wGB Dgbc_an1y2a Deff1y' #The obvious dependence on Db is included in Deff1y
    function = '(2*wGB/L-1) * Deff1y * Dgbc_an1y2a / (2*wGB/L * Deff1y - Dgbc_an1y2a)'
  []
  [Diffusion_coefficient_D_an1y2a]
    type = DerivativeParsedMaterial
    f_name = 'D_an1y2a'
    args = 'bnds'
    material_property_names = 'Dbc_an1y2a Dgbc_an1y2a hgb(bnds)'
    function = '(1-hgb)*Dbc_an1y2a+hgb*Dgbc_an1y2a'
    # outputs = exodus
    derivative_order = 2
  []
  #========================================================= Analytical 4 - 1x2b
  [Equation_coefficient_Db_corrected_a_an1x2b] # coefficient a in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'a_Db_an1x2b'
    material_property_names = 'L wGB'
    function = '-(1-wGB/L)*(1-L/2/wGB)-wGB/L*(1-L/2/wGB)^2'
  []
  [Equation_coefficient_Db_corrected_b_an1x2b] # coefficient b in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'b_Db_an1x2b'
    material_property_names = 'L wGB Deff1x Deff22'
    function = '((1-wGB/L+wGB/L*wGB/L)*(1-L/2/wGB) + wGB/L*(1-wGB/L))*Deff22 - Deff1x/2'
  []
  [Equation_coefficient_Db_corrected_c_an1x2b] # coefficient c in quadratic equation for corrected Db
    type = ParsedMaterial
    f_name = 'c_Db_an1x2b'
    material_property_names = 'L wGB Deff1x Deff22'
    function = '((1-wGB/L+wGB/L*wGB/L))*L/2/wGB*Deff22*Deff1x - L/4/wGB*Deff1x*Deff1x'
  []
  [Diffusion_coefficient_Db_corrected_scale_up_an1x2b] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dbc_an1x2b'
    material_property_names = 'a_Db_an1x2b b_Db_an1x2b c_Db_an1x2b'
    function = '(-b_Db_an1x2b-sqrt(b_Db_an1x2b*b_Db_an1x2b-4*a_Db_an1x2b*c_Db_an1x2b))/2/a_Db_an1x2b'
  []
  [Diffusion_coefficient_Dgb_corrected_scale_up_an1x2b] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dgbc_an1x2b'
    material_property_names = 'L wGB Dbc_an1x2b Deff1x' #The obvious dependence on Dgb is included in Deff1x
    function = '(1-L/2/wGB)*Dbc_an1x2b + L/2/wGB*Deff1x'
  []
  [Diffusion_coefficient_D_an1x2b]
    type = DerivativeParsedMaterial
    f_name = 'D_an1x2b'
    args = 'bnds'
    material_property_names = 'Dbc_an1x2b Dgbc_an1x2b hgb(bnds)'
    function = '(1-hgb)*Dbc_an1x2b+hgb*Dgbc_an1x2b'
    # outputs = exodus
    derivative_order = 2
  []
  #========================================================= Analytical 5 - 1y2b
  [Equation_coefficient_DGB_corrected_a_an1y2b] # coefficient a in quadratic equation for corrected DGB
    type = ParsedMaterial
    f_name = 'a_DGB_an1y2b'
    material_property_names = 'L wGB'
    function = 'wGB/L'
  []
  [Equation_coefficient_DGB_corrected_b_an1y2b] # coefficient b in quadratic equation for corrected DGB
    type = ParsedMaterial
    f_name = 'b_DGB_an1y2b'
    material_property_names = 'L wGB Deff1y Deff22'
    function = '-(1-wGB/L+wGB/L*wGB/L)*Deff22 + (1-3*wGB/L)*Deff1y'
  []
  [Equation_coefficient_DGB_corrected_c_an1y2b] # coefficient c in quadratic equation for corrected DGB
    type = ParsedMaterial
    f_name = 'c_DGB_an1y2b'
    material_property_names = 'L wGB Deff1y Deff22'
    function = 'wGB/L*(1+wGB/L)*Deff1y*Deff22'
  []
  [Diffusion_coefficient_DGB_corrected_scale_up_an1y2b] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dgbc_an1y2b'
    material_property_names = 'a_DGB_an1y2b b_DGB_an1y2b c_DGB_an1y2b'
    function = '(-b_DGB_an1y2b+sqrt(b_DGB_an1y2b*b_DGB_an1y2b-4*a_DGB_an1y2b*c_DGB_an1y2b))/2/a_DGB_an1y2b'
  []
  [Diffusion_coefficient_Db_corrected_scale_up_an1y2b] # correction to maintain D_eff when scaling up
    type = ParsedMaterial
    f_name = 'Dbc_an1y2b'
    material_property_names = 'L wGB Dgbc_an1y2b Deff1y' #The obvious dependence on Db is included in Deff1y
    function = '(2*wGB/L-1) * Deff1y * Dgbc_an1y2b / (2*wGB/L * Deff1y - Dgbc_an1y2b)'
  []
  [Diffusion_coefficient_D_an1y2b]
    type = DerivativeParsedMaterial
    f_name = 'D_an1y2b'
    args = 'bnds'
    material_property_names = 'Dbc_an1y2b Dgbc_an1y2b hgb(bnds)'
    function = '(1-hgb)*Dbc_an1y2b+hgb*Dgbc_an1y2b'
    # outputs = exodus
    derivative_order = 2
  []
[]

[Postprocessors]
  [D_x_AEH_an1x1y] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH_an1x1y cy_AEH_an1x1y'
    col = 0
    row = 0
    diffusion_coefficient = D_an1x1y
    # execute_on = INITIAL
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [D_x_AEH_an1x2a] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    # variable = cx_AEH_an1x2a
    chi = 'cx_AEH_an1x2a cy_AEH_an1x2a'
    col = 0
    row = 0
    diffusion_coefficient = D_an1x2a
    # execute_on = INITIAL
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [D_x_AEH_an1y2a] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH_an1y2a cy_AEH_an1y2a'
    col = 0
    row = 0
    diffusion_coefficient = D_an1y2a
    # execute_on = INITIAL
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [D_x_AEH_an1x2b] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH_an1x2b cy_AEH_an1x2b'
    col = 0
    row = 0
    diffusion_coefficient = D_an1x2b
    # execute_on = INITIAL
    # scale_factor = 1e6 #Scale due to length scale of problem
  []
  [D_x_AEH_an1y2b] #Effective thermal conductivity in x-direction from AEH
    type = HomogenizedThermalConductivity
    chi = 'cx_AEH_an1y2b cy_AEH_an1y2b'
    col = 0
    row = 0
    diffusion_coefficient = D_an1y2b
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
[]

# It converges faster if all the residuals are at the same magnitude
[Debug]
  show_var_residual_norms = true
[]

[Preconditioning]
  [SMP]
    type = SMP
    off_diag_row = 'cx_AEH_an1x1y cx_AEH_an1x2a cx_AEH_an1y2a cx_AEH_an1x2b cx_AEH_an1y2b'
    off_diag_column = 'cx_AEH_an1x1y cx_AEH_an1x2a cx_AEH_an1y2a cx_AEH_an1x2b cx_AEH_an1y2b'
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
