class WaitProxyJudgeJob < ApplicationJob
  queue_as :default

  def perform
    remain = false
    begin
      remain ||= Judges::POJ.new().fetch_results
      remain ||= Judges::CF.new().fetch_results
    rescue Exception => e
      Rails.logger.error e
    end
    sleep 1
    WaitProxyJudgeJob.perform_later if remain
  end
end
