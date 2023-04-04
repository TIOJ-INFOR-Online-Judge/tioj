class AnnouncementsController < InheritedResources::Base
  actions :index, :create, :edit, :update, :destroy # no :show & :new
  before_action :set_contest, only: [:create, :index]
  before_action :set_announcement, only: [:edit, :update, :destroy]
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

  def set_contest
    @contest = Contest.find(params[:contest_id]) if params[:contest_id]
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
    @contest = @announcement.contest
    if @contest
      raise_not_found if params[:contest_id] && @contest.id != params[:contest_id].to_i
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
