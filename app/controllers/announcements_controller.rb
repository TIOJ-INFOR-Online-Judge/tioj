class AnnouncementsController < InheritedResources::Base
  actions :index, :create, :edit, :update, :destroy # no :show & :new
  before_action :authenticate_admin!

  def index
    @announcements = @annos
    @announcement = Announcement.new
  end

  def create
    create! { announcements_path }
  end

  def update
    update! { announcements_path }
  end

  private

  def authenticate_admin!
    authenticate_user!
    if not current_user.admin?
      flash[:alert] = 'Insufficient User Permissions.'
      redirect_to root_path
      return
    end
  end

  def announcement_params
    params.require(:announcement).permit(:title, :body)
  end

end
