concentration_scaling = 1e10 # (-)
diffusion_Li2O_preexponential = ${units ${fparse exp(-5.93) * 1e-4} m^2/s -> mum^2/s} # Tritium
solubility_constant_Li2O = ${fparse 2.0568216e-05 * 4.04e28 / 1e18 / concentration_scaling}

[StochasticTools]
[]

# [Distributions]
#   [diffusivity_pre_exponential]
#     type = Uniform
#     lower_bound = ${fparse ${diffusion_Li2O_preexponential} * 1e-4}
#     upper_bound = ${fparse ${diffusion_Li2O_preexponential} * 1e4}
#   []
#   [solubility_pre_exponential]
#     type = Uniform
#     lower_bound = ${fparse ${solubility_constant_Li2O} * 1e-4}
#     upper_bound = ${fparse ${solubility_constant_Li2O} * 1e4}
#   []
# []

[Samplers]
  # [hypercube]
  #   type = LatinHypercube
  #   num_rows = 5000
  #   distributions = 'diffusivity_pre_exponential solubility_pre_exponential'
  # []
  [cartesian_sampling]
    type = CartesianProduct
    # type = Cartesian1D
    linear_space_items = ' ${fparse ${diffusion_Li2O_preexponential} * 1e-4} 1e2 5
                           ${fparse ${solubility_constant_Li2O} * 1e-4}      1e2 5'
    # nominal_values = '${diffusion_Li2O_preexponential} ${solubility_constant_Li2O}'
    execute_on = 'initial timestep_end'
  []
[]

[MultiApps]
  [runner]
    type = SamplerFullSolveMultiApp
    sampler = cartesian_sampling
    input_files = 'Li2O_diffusion_1d.i'
    mode = batch-restore
  []
[]

[Transfers]
  [parameters]
    type = SamplerParameterTransfer
    to_multi_app = runner
    sampler = cartesian_sampling
    parameters = 'diffusion_Li2O_preexponential solubility_constant_Li2O'
  []
  [results]
    type = SamplerReporterTransfer
    from_multi_app = runner
    sampler = cartesian_sampling
    stochastic_reporter = results
    from_reporter = 'avg_flux_total/value'
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
