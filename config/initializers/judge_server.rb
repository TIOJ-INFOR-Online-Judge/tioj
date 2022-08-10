Rails.application.config.to_prepare do
  if defined?(Rails::Server) or File.basename($0) == 'tioj'
    JudgeServer.where(online: true).all.each do |x|
      ActionCable.server.remote_connections.where(judge_server: x).disconnect
    end
    JudgeServer.update_all(online: false)
  end
end
