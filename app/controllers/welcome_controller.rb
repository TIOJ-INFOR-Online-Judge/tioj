class WelcomeController < ApplicationController
  def index
    @bulletins = Article.order(pinned: :desc, id: :desc).includes(:user)
    unless user_signed_in?
      @bulletins = @bulletins.where(public: true)
    end
    @bulletins = @bulletins.limit(5)
    @contests = Contest.order(id: :desc).limit(3)
    @users = get_sorted_user(10)
  end
end
