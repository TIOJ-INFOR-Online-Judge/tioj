module SingleContestAuthenticationConcern
  extend ActiveSupport::Concern

 protected

  def effective_admin?
    current_user&.admin? && @layout != :single_contest
  end

  def current_user
    if @layout == :single_contest
      user_id = session.dig(:single_contest, @contest.id, :user_id)
      # TODO: store partial password for password change?
      return nil if user_id.nil?
      # This cache only lives in a request
      @user_cache ||= {}
      return @user_cache[user_id] if @user_cache.key?(user_id)
      ret = User.find_by(id: user_id)
      @user_cache[user_id] = ret
      return ret
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

  def authenticate_user!
    if @layout == :single_contest
      return if user_signed_in?
      redirect_to sign_in_single_contest_path(@contest)
    end
    super
  end
end