Rails.application.config.to_prepare do
  if (defined?(Rails::Server) or File.basename($0) == 'rack-preloader.rb')
    CompilerHelper.generate_table
  end
end
