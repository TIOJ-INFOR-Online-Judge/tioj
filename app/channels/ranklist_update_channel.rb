class RanklistUpdateChannel < ApplicationCable::Channel
  def subscribed
    # reject() will return true
    reject && return unless params[:id].is_a? Integer
    contest = Contest.find_by_id(params[:id])
    reject && return unless contest.is_started?
    if !contest.dashboard_during_contest && contest.is_running? && !effective_admin?
      stream_from "ranklist_update_#{contest.id}_#{current_user.id}"
      stream_from "ranklist_update_#{contest.id}_global"
    else
      stream_from "ranklist_update_#{contest.id}"
    end
  end

  def unsubscribed
  end
end
