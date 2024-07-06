class WaitProxyJudgeJob < ApplicationJob
  queue_as :default

  def perform(submission, problem)
    begin
      case problem.proxyjudge_type.to_sym
      when :codeforces
        @proxy = Judges::CF.new()
      when :poj
        @proxy = Judges::POJ.new()
      else
        raise 'Unknown problem.proxyjudge_type'
      end

      loop do
        @status = @proxy.fetch_submission_status(problem.proxyjudge_args, submission.proxyjudge_id)
        if @status.present?
          break
        end
        sleep 3
      end

      submission.result = @status[:verdict]
      submission.total_time = @status[:time]
      submission.total_memory = @status[:memory]
      submission.save

      ActionCable.server.broadcast("submission_#{submission.id}_overall",
         [:id, :score, :result, :total_time, :total_memory, :message].map{|attr|
           [attr, submission.read_attribute(attr)]
         }.to_h
      )

    rescue Exception => e
      Rails.logger.error e
      submission.result = "JE"
      submission.save
    end
  end
end
