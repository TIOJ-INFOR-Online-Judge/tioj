class SubmissionChannel < ApplicationCable::Channel
  def subscribed
    # reject() will return true
    if params[:id].is_a? Integer
      submission = Submission.find_by_id(params[:id])
      reject && return unless submission&.allowed_for(current_user)
      stream_from "submission_#{submission.id}"
      stream_from "submission_#{submission.id}_overall"
      init_data(submission)
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

  def init_data(submission)
    ActionCable.server.broadcast("submission_#{submission.id}", {
      td_set_scores: submission.calc_td_set_scores,
      tasks: submission.submission_tasks.map do |t|
        [:position, :result, :time, :rss, :vss, :score, :message_type, :message].map{|attr|
          [attr, t.read_attribute(attr)]
        }.to_h
      end
    })
    ActionCable.server.broadcast("submission_#{submission.id}_overall", [:id, :message, :score, :result, :total_time, :total_memory].map{|attr|
      [attr, submission.read_attribute(attr)]
    }.to_h)
  end
end
