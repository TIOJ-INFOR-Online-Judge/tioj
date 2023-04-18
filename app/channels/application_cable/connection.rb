module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :judge_server, :current_user, :is_single_contest
    
    def initialize(*args)
      super
      @mutex = Mutex.new
    end

    def connect
      self.is_single_contest = request.headers['HTTP_SINGLECONTEST'] == '1'
      if request.params['key']
        @mutex.synchronize do
          return if @disconnected
          judge_server = find_judge_server
          judge_server.with_lock do
            reject_unauthorized_connection if judge_server.online
            judge_server.update(online: true)
          end
          self.judge_server = judge_server
        end
      else
        self.current_user = find_user
      end
    end

    def disconnect
      # connect and disconnect may be called in different thread simutaneously, thus use a mutex to prevent races
      @mutex.synchronize do
        if self.judge_server
          begin
            self.judge_server.update(online: false)
          rescue ActiveRecord::StatementInvalid => e
            # This happens once in a while when the server restarts;
            #  disconnect the connection pool to prevent the server being stuck by ~1min because of stale connections
            ActiveRecord::Base.connection_pool.disconnect
          end
        end
        @disconnected = true
      end
    end

    private

    def find_judge_server
      key = request.params['key']
      version = request.params['version']
      reject_unauthorized_connection if not key or not version
      reject_unauthorized_connection if not Gem::Version.new(version).between?(Gem::Version.new('1.3.0') , Gem::Version.new('2'))
      judge = JudgeServer.find_by(key: key)
      reject_unauthorized_connection if not judge or (not (judge.ip || "").empty? and judge.ip != request.remote_ip)
      judge
    end

    def find_user
      user_id = request.session&.dig('warden.user.user.key', 0, 0)
      return nil if not user_id
      user = User.find_by(id: user_id)
      reject_unauthorized_connection if not user
      user
    end
  end
end
