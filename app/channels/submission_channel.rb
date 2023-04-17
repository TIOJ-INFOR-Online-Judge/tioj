class SubmissionChannel < ApplicationCable::Channel
  def subscribed
    # reject() will return true
    if params[:id].is_a? Integer
      submission = Submission.find_by_id(params[:id])
      reject && return unless submission&.allowed_for(current_user)
      with_detail = submission&.tasks_allowed_for(current_user)
      stream_from "submission_#{submission.id}_subtasks"
      stream_from "submission_#{submission.id}_testdata" if with_detail
      stream_from "submission_#{submission.id}_overall"
      init_data(submission, with_detail)
    else
      reject && return if params[:id].size > 20
      submissions = Submission.where(id: params[:id]).filter{|s| s.allowed_for(current_user)}
      reject && return if not submissions
      submissions.each do |s|
        stream_from "submission_#{s.id}_overall"
      end
    end
  end

  def unsubscribed
  end

  private

  def init_data(submission, with_detail)
    ActionCable.server.broadcast("submission_#{submission.id}_subtasks", {subtask_scores: submission.calc_subtask_result})
    ActionCable.server.broadcast("submission_#{submission.id}_testdata", {
      testdata: submission.submission_testdata_results.map do |t|
        [:position, :result, :time, :rss, :vss, :score, :message_type, :message].map{|attr|
          [attr, t.read_attribute(attr)]
        }.to_h
      end
    }) if with_detail
    ActionCable.server.broadcast("submission_#{submission.id}_overall", [:id, :message, :score, :result, :total_time, :total_memory].map{|attr|
      [attr, submission.read_attribute(attr)]
    }.to_h)
  end
end
