class WaitProxyJudgeJob < ApplicationJob
  queue_as :default

  # TODO: start this job on application start

  def perform
    remain = false

    proxyjudge_config = Rails.configuration.x.settings.dig(:proxyjudge)
    if proxyjudge_config&.include?(:qoj)
      remain ||= Judges::QOJ.new().fetch_results
    end
    if proxyjudge_config&.include?(:codeforces)
      remain ||= Judges::Codeforces.new().fetch_results
    end
    if proxyjudge_config&.include?(:poj)
      remain ||= Judges::POJ.new().fetch_results # it takes so long to fetch on POJ
    end

    sleep 1

    WaitProxyJudgeJob.perform_later if remain
  end
end
