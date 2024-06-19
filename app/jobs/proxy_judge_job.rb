class ProxyJudgeJob < ApplicationJob
  queue_as :default

  # def initialize(*args)
  #   super
  #   Rails.logger.info "args = #{args}"
  # end

  # TODO add panel to check proxy judge active job status?
  def perform(submission, problem)
    code = submission.code_content.code
    code << "\n// tioj-proxy - " << rand(8**36).to_s(36) # XXX: hack for exactly same code
    # TODO this comment style only works for C/C++

    # Rails.logger.info code
    # Rails.logger.info "proxy_judge_type = #{problem.proxy_judge_type}"
    # Rails.logger.info "proxy_judge_args = #{problem.proxy_judge_args}"
    # Rails.logger.info submission.compiler
    # return

    if problem.proxy_judge_type == 'CF' then
      @proxy = Judges::CF.new()
    elsif problem.proxy_judge_type == 'POJ' then
      @proxy = Judges::POJ.new()
    else
      raise 'Unknown problem.proxy_judge_type'
    end

    @proxy.submit!(problem.proxy_judge_args, submission.compiler.name, code)

    submission.result = "WaitingProxy"
    submission.save

    loop do
      if @proxy.done?
        @proxy.summary!
        submission.result = @proxy.verdict
        submission.total_time = @proxy.time
        submission.total_memory = @proxy.memory
        submission.save
        break
      end
      sleep 3
    end
  end
end
