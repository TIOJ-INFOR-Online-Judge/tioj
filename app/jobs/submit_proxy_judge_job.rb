class SubmitProxyJudgeJob < ApplicationJob
  queue_as :default

  def perform(submission, problem)
    code = submission.code_content.code
    case submission.compiler.format_type # XXX: hack for exactly same code
    when "language-c", "language-cpp"
      code << "\n// tioj-proxy nonce=" << submission.proxyjudge_nonce
    when "language-haskell"
      code << "\n-- tioj-proxy nonce=" << submission.proxyjudge_nonce
    when "language-python"
      code << "\n# tioj-proxy nonce=" << submission.proxyjudge_nonce
    end

    begin
      case problem.proxyjudge_type.to_sym
      when :codeforces
        @proxy = Judges::CF.new()
      when :poj
        @proxy = Judges::POJ.new()
      else
        raise 'Unknown problem.proxyjudge_type'
      end

      # the submit! method will update the submission's proxyjudge_id
      @proxy.submit!(problem.proxyjudge_args, submission.compiler.name, code, submission)
      submission.update!(result: "received")
      # TODO check broadcast working?
      ActionCable.server.broadcast("submission_#{submission.id}_overall",
                                   {result: 'received', id: submission.id})

      WaitProxyJudgeJob.perform_later(submission, problem)

    rescue Exception => e
      Rails.logger.error e
      submission.result = "JE"
      submission.save
    end
  end
end
