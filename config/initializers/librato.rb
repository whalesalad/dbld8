if Rails.env.production?
  require 'metriks'
  require 'metriks/reporter/librato_metrics'
  Metriks::Reporter::LibratoMetrics.new(Rails.configuration.librato['user'], Rails.configuration.librato['token']).start
end