module SingleContestAuthenticationConcern
  extend ActiveSupport::Concern

 protected

  def effective_admin?
    current_user&.admin? && @layout != :single_contest
  end

  def current_user
    if @layout == :single_contest
      return nil
    end
    super
  end

  def user_signed_in?
    if @layout == :single_contest
      return false
    end
    super
  end

  def user_session
    if @layout == :single_contest
      return 'meow'
    end
    super
  end

  def authenticate_user!
    if @layout == :single_contest
    end
    super
  end
end