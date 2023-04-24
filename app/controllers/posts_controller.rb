class PostsController < ApplicationController
  include PostFilteringConcern

  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_posts, :check_contest_and_problem
  before_action :check_post_create, only: [:new, :create]
  before_action :set_post_types, only: [:new, :create, :edit, :update]
  before_action :check_user!, only: [:edit, :update, :destroy]
  before_action :check_params!, only: [:create, :update]
  layout :set_contest_layout, only: [:show, :index, :new, :edit]

  helper_method :allow_edit
  helper_method :allow_set_visibility

  # GET /posts
  # GET /posts.json
  def index
    @posts = @posts.page(params[:page]).includes(:user).preload(comments: :user)
    if @contest
      @title = "Q & A"
    elsif @problem
      @title = "Discuss - #{@problem.id}"
    else
      @title = "Discuss"
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = @posts.find(params[:id])
  end

  # GET /posts/new
  def new
    @post = @posts.build
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  # POST /posts.json
  def create
    @post = @posts.build(post_params)
    @post.user_id = current_user.id
    @post.postable = @postable

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
      format.html { redirect_to @page_path }
    end
  end

  private

  def allow_edit(post)
    effective_admin? || (current_user&.id == post.user_id && !@contest)
  end

  def allow_set_visibility
    !@contest || effective_admin?
  end

  def check_post_create
    check_problem_allow_create
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_posts
    filter_posts
    @posts = @posts.order(updated_at: :desc)
  end

  def set_post_types
    if @contest
      @post_types = [['discuss', nil]]
    else
      @post_types = Post.post_types.keys
      @post_types.delete('solution') unless @problem && current_user&.admin?
      if @problem
        desc = {
          "discuss" => "Normal discussion",
          "solution" => "Solution (pinned)",
          "issue" => "Issue report (also shown on global discuss page)",
        }
      else
        desc = {
          "discuss" => "Normal discussion",
          "issue" => "Issue report",
        }
      end
      @post_types = @post_types.map {|x| [desc[x], x]}
    end
  end

  def check_user!
    @post = @posts.find(params[:id])
    unless allow_edit(@post)
      flash[:alert] = 'Insufficient User Permissions.'
      redirect_to action: 'index'
      return
    end
  end

  def check_params!
    unless allow_set_visibility
      params[:post][:global_visible] = '0' if @contest
      params[:post][:user_visible] = '0' if @contest
    end
    if not @post_types.map{|x| x[1]}.include?(params[:post][:post_type])
      flash[:alert] = 'Invalid post type.'
      redirect_to action: 'index'
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
      :post_type,
      :global_visible,
      :user_visible,
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
