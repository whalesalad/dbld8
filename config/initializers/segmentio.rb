if Rails.env.development?
  Analytics.init(
    secret: Rails.configuration.segment_io_secret,
    on_error: Rails.configuration.segment_io_error
  )
end
