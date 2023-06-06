module SingleContestAuthenticationConcern
  extend ActiveSupport::Concern

 protected

  def effective_admin?
    current_user&.admin? && @layout != :single_contest
  end

  def current_user
    if @layout == :single_contest
      ret = get_single_contest_user
      return nil if ret.nil?
      return @contest.user_registered?(ret) ? ret : nil
    end
    super
  end

  def user_signed_in?
    super
  end

  def user_session
    if @layout == :single_contest
      return session.dig(:single_contest, @contest.id, :user_session)
    end
    super
  end

  def authenticate_user!(opts = {})
    if @layout == :single_contest
      return if user_signed_in?
      redirect_to sign_in_single_contest_path(@contest)
    end
    super
  end

 private
  
  def get_single_contest_user
    user_id = session.dig(:single_contest, @contest.id, :user_id)
    return nil if user_id.nil?
    # This cache only lives in a request
    @user_cache ||= {}
    return @user_cache[user_id] if @user_cache.key?(user_id)
    ret = UserBase.find_by(id: user_id)
    @user_cache[user_id] = ret
    return ret
  end
end