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

  def current
    authenticate_user!
    redirect_to user_path(current_user) + '/' + params[:path]
  end

  private

  def authenticate_current!
    unless current_user&.admin? or current_user&.username == params[:id]
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
