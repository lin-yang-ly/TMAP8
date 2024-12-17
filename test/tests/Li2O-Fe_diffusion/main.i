concentration_scaling = 1e10 # (-)
diffusion_Li2O_preexponential = ${units ${fparse exp(-5.93) * 1e-4} m^2/s -> mum^2/s} # Tritium
solubility_constant_Li2O = ${fparse 2.0568216e-05 * 4.04e28 / 1e18 / concentration_scaling}

[StochasticTools]
[]

[Samplers]
  [sampler]
    type = CartesianProduct
    # type = Cartesian1D
    linear_space_items = ' ${fparse ${diffusion_Li2O_preexponential} * 1e-4} 1e2 5
                           ${fparse ${solubility_constant_Li2O} * 1e-4}      1e2 5'
    # nominal_values = '${diffusion_Li2O_preexponential} ${solubility_constant_Li2O}'
    execute_on = 'PRE_MULTIAPP_SETUP'
  []
[]

[MultiApps]
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = sampler
    input_files = 'Li2O_diffusion_1d.i'
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
    param_names = 'diffusion_Li2O_preexponential solubility_constant_Li2O'
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
  execute_on = 'FINAL'
  [out]
    type = JSON
  []
[]
