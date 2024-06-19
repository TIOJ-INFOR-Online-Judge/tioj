class ProxyJudgeJob < ApplicationJob
  queue_as :default

  def initialize(*args)
    super
    @cf = Judges::CF.new()
  end

  # TODO add panel to check proxy judge active job status?
  def perform(submission, problem)
    code = submission.code_content.code
    code << "\n// tioj-proxy - " << rand(8**36).to_s(36) # XXX: hack for exactly same code

    # TODO add proxy judge argument and language
    submission_id = @cf.submit('375E', /.*GNU G++20.*/, code)

    submission.result = "WaitingProxy"
    submission.save

    loop do
      if @cf.done?
        submission.result = @cf.verdict
        submission.total_time = @cf.time
        submission.total_memory = @cf.memory
        submission.save
        break
      end
      sleep 3
    end
  end
end
