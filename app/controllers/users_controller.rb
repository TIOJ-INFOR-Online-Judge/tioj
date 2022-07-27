class UsersController < ApplicationController
  before_action :authenticate_current!, only: [:changed_problems, :changed_submissions]
  before_action :set_user, only: [:show, :changed_problems, :changed_submissions]

  def index
    @users = Kaminari.paginate_array(get_sorted_user).page(params[:page]).per(25)
  end

  def show
    set_user
    @problems = Problem.select(:id).order(id: :asc)
    tried = @user.submissions.select(:problem_id).group(:problem_id)
    ac = @user.submissions.select(:problem_id).where(result: 'AC').group(:problem_id)
    @tried = Array.new(@problems.count + 1)
    tried.each do |t|
      @tried[t.problem_id] = 2
    end
    ac.each do |t|
      @tried[t.problem_id] = 1
    end
  end

  def changed_problems
    ac_cur = @user.submissions.select(:problem_id).where(result: 'AC', contest_id: nil).group(:problem_id).map(&:problem_id)
    ac_old = @user.submissions.select(:problem_id).where(old_result: 'AC', contest_id: nil).group(:problem_id).map(&:problem_id)
    changed = ac_old - ac_cur
    # logger.fatal [ac_cur, ac_old, changed]
    @problems = Problem.where(id: changed)
    @problems = @problems.order(id: :asc).page(params[:page]).per(50)
  end

  def changed_submissions
    if user_signed_in? and current_user.admin? and params[:all_user] == '1'
      @submissions = Submission
    else
      @submissions = @user.submissions
    end
    @submissions = @submissions.where(old_result: 'AC').where.not(result: 'AC')
    if not params[:problem_id].blank?
      @problem = Problem.find(params[:problem_id])
      @submissions = @submissions.where(problem_id: params[:problem_id])
    end
    @submissions = @submissions.where(result: params[:filter_status]) if not params[:filter_status].blank?
    @submissions = @submissions.order(id: :desc).page(params[:page]).preload(:user, :compiler, :problem)
  end

  private

  def authenticate_current!
    unless (user_signed_in? and current_user.admin?) or (user_signed_in? and current_user.username == params[:id])
      flash[:alert] = 'Insufficient User Permissions.'
      redirect_to action: 'index'
      return
    end
  end

  def set_user
    begin
      @user = User.friendly.find(params[:id])
      if @user.blank?
        redirect_to users_path, :alert => "Username '#{params[:id]}' not found."
        return
      end
    rescue ActiveRecord::RecordNotFound => e
      redirect_to users_path, :alert => "Username '#{params[:id]}' not found."
      return
    end
  end
end
