concentration_scaling = 1e10 # (-)
# diffusion_Li2O_preexponential = ${units ${fparse exp(-5.93) * 1e-4} m^2/s -> mum^2/s} # Tritium
# solubility_constant_Li2O = ${fparse 2.0568216e-05 * 4.04e28 / 1e18 / concentration_scaling}
diffusion_Fe_preexponential = ${units 1.9e-6 m^2/s -> mum^2/s} # Tritium
solubility_constant_Fe = ${fparse 1.87e-6 / 3.016 * 55.845 * 4.04e28 / 1e18 / concentration_scaling}

[StochasticTools]
[]

[Samplers]
  # [sampler]
  #   type = InputMatrix
  #   matrix = '${fparse ${diffusion_Li2O_preexponential} * 1e-3}  ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e-2}  ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e-1}  ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e1}   ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e2}   ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e3}   ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e-3};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e-2};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e-1};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e0};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e1};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e2};
  #             ${fparse ${diffusion_Li2O_preexponential} * 1e0}   ${fparse ${solubility_constant_Li2O} * 1e3}'
  #   execute_on = 'PRE_MULTIAPP_SETUP'
  # []
  [sampler]
    type = InputMatrix
    matrix = '${fparse ${diffusion_Fe_preexponential} * 1e-3}  ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e-2}  ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e-1}  ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e1}   ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e2}   ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e3}   ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e-3};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e-2};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e-1};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e0};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e1};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e2};
              ${fparse ${diffusion_Fe_preexponential} * 1e0}   ${fparse ${solubility_constant_Fe} * 1e3}'
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
  # [sampler]
  #   # type = CartesianProduct
  #   type = Cartesian1D
  #   linear_space_items = ' ${fparse ${diffusion_Fe_preexponential} * 1e-1} ${fparse ${diffusion_Fe_preexponential} * 2e-1} 7
  #                          ${fparse ${solubility_constant_Fe} * 1e-1}      ${fparse ${solubility_constant_Fe} * 2e-1} 7'
  #   nominal_values = '${diffusion_Fe_preexponential} ${solubility_constant_Fe}'
  #   execute_on = 'PRE_MULTIAPP_SETUP'
  # []
[]

[MultiApps]
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = sampler
    # input_files = 'Li2O_diffusion_2d.i'
    input_files = 'Fe_diffusion_2d.i'
    cli_args = 'Outputs/console=false'
  []
[]

[Transfers]
  # Input
  # [parameters]
  #   type = SamplerParameterTransfer
  #   to_multi_app = runner
  #   sampler = sampler
  #   parameters = 'diffusion_Li2O_preexponential solubility_constant_Li2O'
  # []

  # Output
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = sampler
    stochastic_reporter = results
    from_reporter = 'avg_flux_total/value'
  []
[]

[Controls]
  # Input
  [cmdline]
    type = MultiAppSamplerControl
    multi_app = runner
    sampler = sampler
    # param_names = 'diffusion_Li2O_preexponential solubility_constant_Li2O'
    param_names = 'diffusion_Fe_preexponential solubility_constant_Fe'
  []
[]

[Reporters]
  [results]
    type = StochasticReporter
  []
  [stats]
    type = StatisticsReporter
    reporters = 'results/results:avg_flux_total:value'
    compute = 'mean stddev'
    ci_method = 'percentile'
    ci_levels = '0.05 0.95'
  []
[]

[Outputs]
  # file_base = 'multiapp_2d/Li2O_results'
  file_base = 'multiapp_2d/Fe_results'
  execute_on = 'FINAL'
  [out]
    type = JSON
  []
[]
