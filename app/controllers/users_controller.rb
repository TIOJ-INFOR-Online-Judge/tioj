class UsersController < ApplicationController
  def index
    @users = Kaminari.paginate_array(get_sorted_user).page(params[:page]).per(25)
  end

  def show
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
end
