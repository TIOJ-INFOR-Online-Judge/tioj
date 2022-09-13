if Rails.application.credentials.sentry_dsn
  Sentry.init do |config|
    config.dsn = Rails.application.credentials.sentry_dsn
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sampler = lambda do |sampling_context|
      unless sampling_context[:parent_sampled].nil?
        next sampling_context[:parent_sampled]
      end
      if sampling_context[:transaction_context][:op] == 'rails.action_cable'
        Rails.configuration.x.settings.sentry_sample_rate[:cable]
      else
        Rails.configuration.x.settings.sentry_sample_rate[:normal]
      end
    end
  end
end
