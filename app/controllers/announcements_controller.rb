class AnnouncementsController < InheritedResources::Base
  actions :index, :create, :edit, :update, :destroy # no :show & :new
  before_action :set_announcement, only: [:edit, :update, :destroy]
  before_action :redirect_contest, only: [:edit]
  before_action :set_paths, only: [:create, :update, :destroy]
  before_action :authenticate_admin!
  layout :set_contest_layout, only: [:index, :edit]

  def index
    @announcements = @annos
    @announcement = Announcement.new
  end

  def create
    if @contest
      @announcement = @contest.announcements.build(announcement_params)
    end
    create! { @page_path }
  end

  def update
    update! { @page_path }
  end

  def destroy
    destroy! { @page_path }
  end

  private

  def set_announcement
    @announcement = Announcement.find(params[:id])
    raise_not_found if @contest && @contest.id != @announcement.contest_id
    @contest ||= @announcement.contest
  end

  def redirect_contest
    if @layout != :contest and @announcement.contest_id
      redirect_to URI::join(contest_url(@contest) + '/', request.fullpath[1..]).to_s
    end
  end

  def set_paths
    if @contest
      @page_path = contest_announcements_path(@contest)
    else
      @page_path = announcements_path
    end
  end

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
