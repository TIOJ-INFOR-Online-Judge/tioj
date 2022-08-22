module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :judge_server
    
    def initialize(*args)
      super
      @mutex = Mutex.new
    end

    def connect
      @mutex.synchronize do
        return if @disconnected
        judge_server = find_judge_server
        judge_server.with_lock do
          reject_unauthorized_connection if judge_server.online
          judge_server.update(online: true)
        end
        self.judge_server = judge_server
      end
    end

    def disconnect
      # connect and disconnect may be called in different thread simutaneously, thus use a mutex to prevent races
      @mutex.synchronize do
        if self.judge_server
          self.judge_server.update(online: false)
        end
        @disconnected = true
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
