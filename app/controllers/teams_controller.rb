class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: [:show, :edit, :update, :destroy, :invite, :invite_accept]
  before_action :check_user_in_team!, only: [:edit, :update, :destroy]

  def index
    @teams = Team.order(id: :desc).page(params[:page]).per(100)
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

  private

  def set_team
    begin
      @team = Team.friendly.find(params[:id])
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
