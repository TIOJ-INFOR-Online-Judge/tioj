Rails.application.config.to_prepare do
  if defined?(Rails::Server) or File.basename($0) == 'tioj'
    CompilerHelper.generate_table
  end
end
