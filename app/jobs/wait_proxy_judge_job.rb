class WaitProxyJudgeJob < ApplicationJob
  queue_as :default

  # TODO: start this job on application start

  def perform
    remain = false
    remain ||= Judges::POJ.new().fetch_results
    remain ||= Judges::Codeforces.new().fetch_results
    sleep 1
    WaitProxyJudgeJob.perform_later if remain
  end
end
