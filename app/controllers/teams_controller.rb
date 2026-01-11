class TeamsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_team, except: [:index, :new, :create]
  before_action :check_user_in_team!, only: [:edit, :update, :destroy, :renew_token, :remove_user]
  before_action :authenticate_admin!, only: [:add_user]

  def index
    if params[:search_username].present?
      user = User.find_by(username: params[:search_username])
      if not user then
        redirect_to teams_path, alert: 'No such user.'
        return
      end
      @teams = user.teams
    else
      @teams = Team.all
    end
    if params[:search_teamname].present?
      sanitized = ActiveRecord::Base.send(:sanitize_sql_like, params[:search_teamname])
      @teams = @teams.where("name LIKE ?", "%#{sanitized}%")
    end
    if current_user
      teams = Team.arel_table
      teams_user = TeamUserJoint.arel_table
      exists_for_user = Arel::Nodes::Exists.new(
        teams_user.project('*').where(
          teams_user[:team_id].eq(teams[:id]).and(teams_user[:user_id].eq(current_user.id))
        )
      )
      @teams = @teams.order(exists_for_user.desc, teams[:id].desc)
    else
      @teams = @teams.order(id: :desc)
    end
    @teams = @teams.includes(:users).page(params[:page]).per(50)
  end

  def show
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    @team.generate_random_avatar
    @team.team_user_joints = [TeamUserJoint.new(user: current_user, team: @team)]
    # We need a global lock for both team and user checks
    Team.with_advisory_lock('member') do
      if @team.save
        redirect_to @team, notice: 'Team was successfully created.'
      else
        @team.errors.merge! @team.team_user_joints.first.errors
        render action: "new"
      end
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

    team_user = TeamUserJoint.new(user: current_user, team: @team)
    Team.with_advisory_lock('member') do
      if team_user.save
        redirect_to @team, notice: 'Joined successfully.'
      else
        @team.errors.merge! team_user.errors
        render action: "invite"
      end
    end
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
      flash[:notice] = 'The token was successfully renewed.'
    else
      flash[:alert] = 'Failed to renew token.'
    end

    redirect_to edit_team_path(@team)
  end

  def add_user
    user_to_add = User.find_by(username: params[:username])
    if not user_to_add
      redirect_to @team, alert: 'No such user.'
      return
    end

    team_user = TeamUserJoint.new(user: user_to_add, team: @team)
    Team.with_advisory_lock('member') do
      if team_user.save
        redirect_to @team, notice: "User #{user_to_add.username} was successfully added to the team."
      else
        @team.errors.merge! team_user.errors
        render action: "show"
      end
    end
  end

  def remove_user
    user_to_remove = User.find(params[:user_id])

    team_user = @team.team_user_joints.find_by(user_id: user_to_remove.id)
    Team.with_advisory_lock('member') do
      if team_user.destroy
        redirect_to @team, notice: "User #{user_to_remove.username} was successfully removed from the team."
      else
        @team.errors.merge! team_user.errors
        render action: "show"
      end
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(
      :name,
      :avatar, :avatar_cache,
      :motto,
      :school
    )
  end

  def check_user_in_team!
    raise_not_found unless effective_admin? or @team.users.include?(current_user)
  end
end
