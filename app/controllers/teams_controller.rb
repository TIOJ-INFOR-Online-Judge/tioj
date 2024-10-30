class TeamsController < ApplicationController
  before_action :set_team, only: [:show, :edit, :update, :destroy]

  def index
    @teams = Team.order(id: :desc).page(params[:page])
  end

  def show
  end

  def new
    @team = Team.new
    @team.users = [current_user]
  end

  def create
    @team = Team.new(team_params)
    @team.generate_random_avatar
    if @team.save
      redirect_to @team, notice: 'Team was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
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
      :nickname,
      :school,
      user_ids: []
    )
  end
end
