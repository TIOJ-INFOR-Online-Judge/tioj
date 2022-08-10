module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :judge_server

    def connect
      self.judge_server = find_judge_server
      self.judge_server.with_lock do
        reject_unauthorized_connection if self.judge_server.online
        self.judge_server.update(online: true)
      end
    end

    def disconnect
      if self.judge_server
        self.judge_server.update(online: false)
      end
    end

    private

    def find_judge_server
      key = request.params['key']
      if not key
        reject_unauthorized_connection
      end
      judge = JudgeServer.find_by(key: key)
      if not judge or (not (judge.ip || "").empty? and judge.ip != request.remote_ip)
        reject_unauthorized_connection
      end
      judge
    end
  end
end
