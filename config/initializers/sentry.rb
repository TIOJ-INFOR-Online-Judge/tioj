if Rails.configuration.x.settings.dig(:sentry_dsn)
  Sentry.init do |config|
    config.dsn = Rails.configuration.x.settings.dig(:sentry_dsn)
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sampler = lambda do |sampling_context|
      unless sampling_context[:parent_sampled].nil?
        next sampling_context[:parent_sampled]
      end
      sample_rate = Rails.configuration.x.settings.dig(:sentry_sample_rate)
      if sampling_context[:transaction_context][:op] == 'rails.action_cable'
        sample_rate&.dig(:cable) == nil ? 0.02 : sample_rate[:cable]
      else
        sample_rate&.dig(:normal) == nil ? 0.02 : sample_rate[:normal]
      end
    end
  end
end
