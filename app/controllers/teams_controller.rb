class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :edit, :update, :destroy, :invite, :invite_accept, :renew_token]
  before_action :check_user_in_team!, only: [:edit, :update, :destroy, :renew_token]

  def index
    if params[:search_username].present?
      user = User.find_by(username: params[:search_username])
      if not user then
        redirect_to teams_path, alert: 'No such user.'
        return
      end
      @teams = user.teams
    else
      @teams = Team
    end
    if params[:search_teamname].present?
      sanitized = ActiveRecord::Base.send(:sanitize_sql_like, params[:search_teamname])
      @teams = @teams.where("teamname LIKE ?", "%#{sanitized}%")
    end
    @teams = @teams.order(id: :desc).page(params[:page]).per(100)
  end

  def show
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.generate_random_avatar
    @team.users = [current_user]
    if @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
  end

  def invite
    @token = params[:token]
  end

  def invite_accept
    if @team.token != params[:token]
      redirect_to teams_path, alert: 'Invalid token'
      return
    end

    begin
      @team.users << current_user
      if @team.save
        flash[:notice] = 'Joined successfully.'
      else
        flash[:alert] = 'Failed to join.'
      end
    rescue ActiveRecord::RecordNotUnique
      flash[:alert] = 'User has already been added to this team.'
    end

    redirect_to @team
  end

  def update
    @team.attributes = team_params
    if @team.save
      redirect_to @team, notice: 'Team was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url
  end

  def renew_token
    @team.generate_token
    if @team.save
      redirect_to edit_team_path(@team), notice: 'The token was successfully renewed.'
    else
      flash[:alert] = 'Failed to renew token.'
    end
  end

  private

  def set_team
    begin
      @team = Team.find(params[:id])
      if @team.blank?
        redirect_to teams_path, alert: "Teamname '#{params[:id]}' not found."
        return
      end
    rescue ActiveRecord::RecordNotFound => e
      redirect_to teams_path, alert: "Teamname '#{params[:id]}' not found."
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(
      :teamname,
      :avatar, :avatar_cache,
      :motto,
      :school,
      users_attributes: [
        :id,
        :_destroy
      ]
    )
  end

  def check_user_in_team!
    raise_not_found unless effective_admin? or @team.users.include?(current_user)
  end
end
