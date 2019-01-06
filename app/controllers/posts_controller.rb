class PostsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :check_contest, :set_posts
  before_action :check_user!, only: [:edit, :update, :destroy]
  layout :set_contest_layout, only: [:show, :index, :new, :edit]

  # GET /posts
  # GET /posts.json
  def index
    @posts = @posts.order("updated_at DESC").page(params[:page])
    set_page_title "Discuss"
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = @posts.find(params[:id])
    set_page_title "Discuss - " + @post.id.to_s
  end

  # GET /posts/new
  def new
    @post = @posts.build
    set_page_title "New post"
  end

  # GET /posts/1/edit
  def edit
    set_page_title "Edit post - " + @post.id.to_s
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = @posts.build(post_params)
    @post.user_id = current_user.id
    if params[:contest_id]
      @post.contest_id = @contest.id
    end
    if @contest and not current_user.admin?
      @post.global_visible = false
    end

    respond_to do |format|
      if @post.save
        format.html { redirect_to @page_path, notice: 'Post was successfully created.' }
        format.json { render action: 'show', status: :created, location: @post }
      else
        format.html { render action: 'new' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @page_path, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.json { head :no_content }
      format.html { redirect_to @page_url }
    end
  end

  private
  def check_contest
    unless user_signed_in? and current_user.admin?
      if Contest.where("start_time <= ? AND ? <= end_time AND disable_discussion", Time.now, Time.now).exists?
        redirect_to root_path, :alert => "No discussion during contest."
        return
      end
    end
  end
  
  # Use callbacks to share common setup or constraints between actions.
  def set_posts
    @contest = Contest.find(params[:contest_id]) if params[:contest_id]
    @problem = Problem.find(params[:problem_id]) if params[:problem_id]
    if @contest
      @posts = Post.where('contest_id = ?', params[:contest_id])
    else
      @posts = Post.where('contest_id is NULL')
    end
    if user_signed_in?
      unless current_user.admin?
        @posts = @posts.where('user_id = ? OR global_visible', current_user.id)
      end
    else
      @posts = @posts.where('global_visible')
    end
    @posts = @problem ? @posts.where('problem_id = ?', params[:problem_id]) : @posts
    @page_path = @contest ? contest_posts_path(@contest) : posts_path
    @page_url = @contest ? contest_posts_url(@contest) : posts_url
  end

  def check_user!
    @post = @posts.find(params[:id])
    if not user_signed_in? or (not current_user.admin? and (current_user.id != @post.user_id or @contest))
      flash[:alert] = 'Insufficient User Permissions.'
      redirect_to action:'index'
      return
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(
      :title,
      :content,
      :user_id,
      :problem_id,
      :global_visible,
      :page,
      comments_attributes: [
        :id,
        :title,
        :content,
        :post_id,
        :contest_id
      ]
    )
  end
end
