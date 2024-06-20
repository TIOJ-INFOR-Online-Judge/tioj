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
    # Rails.logger.info "proxyjudge_type = #{problem.proxyjudge_type}"
    # Rails.logger.info "proxyjudge_args = #{problem.proxyjudge_args}"
    # Rails.logger.info submission.compiler
    # return

    case problem.proxyjudge_type.to_sym
    when :codeforces
      @proxy = Judges::CF.new()
    when :poj
      @proxy = Judges::POJ.new()
    else
      raise 'Unknown problem.proxyjudge_type'
    end

    @proxy.submit!(problem.proxyjudge_args, submission.compiler.name, code)

    submission.result = "received"
    submission.save

    loop do
      if @proxy.done?
        @proxy.summary!
        submission.result = @proxy.verdict
        submission.total_time = @proxy.time
        submission.total_memory = @proxy.memory
        submission.save
        # TODO broadcast to submissionchannel?
        break
      end
      sleep 3
    end
  end
end
