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

  def edit_announcement
    authenticate_admin!
  end

  def alter_announcement
    authenticate_admin!
    anno = {:name => params[:name].to_s, :message => params[:message].to_s}
    File.open("public/announcement/anno", "w") do |f|
      f.write(anno.to_json)
    end
    redirect_to root_path
  end
end
