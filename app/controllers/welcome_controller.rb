class WelcomeController < ApplicationController
  def index
    @bulletins = Article.order(pinned: :desc, id: :desc).includes(:user)
    unless user_signed_in?
      @bulletins = @bulletins.where(public: true)
    end
    @bulletins = @bulletins.limit(5)
    @contests = Contest.order(Arel.sql('(start_time <= NOW() AND NOW() < end_time) DESC')).order(start_time: :desc).limit(4)
    @users = get_sorted_user(10)
  end
end
