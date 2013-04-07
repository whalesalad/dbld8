if Rails.env.production?
  require 'metriks'
  require 'metriks/reporter/librato_metrics'
  
  reporter = Metriks::Reporter::LibratoMetrics.new(Rails.configuration.librato['user'], Rails.configuration.librato['token'], on_error: proc { |e| Rails.logger.info("LibratoMetrics: #{ e.message }") })
  reporter.start
end