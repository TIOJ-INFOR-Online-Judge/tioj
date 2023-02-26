Rails.application.config.to_prepare do
  if (defined?(Rails::Server) or File.basename($0) == 'tioj') and ENV['PASSENGER_CABLE']
    # It will automatically disconnect during restart
    JudgeServer.update_all(online: false)
  end
end
