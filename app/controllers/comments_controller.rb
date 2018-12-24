class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  before_action :find_post
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :check_contest
  before_action :check_user!, only: [:create, :edit, :update, :destroy]
  layout :set_contest_layout, only: [:show, :index, :new, :edit]

  # GET /comments
  # GET /comments.json
  def index
    @comments = @post.comments
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = @post.comments.build
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = @post.comments.build(comment_params)
    @comment.user_id = current_user.id

    respond_to do |format|
      if @comment.save
        set_comment_path
        format.html { redirect_to @page_path, notice: 'Comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comment_path }
      else
        format.html { render @page_path }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @page_path, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @page_path }
      format.json { head :no_content }
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

  def check_user!
    if not current_user.admin? and (@contest or (@comment and current_user.id != @comment.user_id))
      flash[:alert] = 'Insufficient User Permissions.'
      redirect_to action:'index'
      return
    end
  end

  def set_comment_path
    @comment_path = @contest ? contest_post_comment_path(@contest, @post, @comment) : post_comment_path(@post, @comment)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
    set_comment_path
  end

  def find_post
    @posts = current_user.admin? ? Post : Post.where('user_id = ? OR global_visible', current_user.id)
    @post = @posts.find(params[:post_id])
    @contest = Contest.find(params[:contest_id]) if params[:contest_id]
    @page_path = @contest ? contest_posts_path(@contest) : posts_path
    @page_url = @contest ? contest_posts_url(@contest) : posts_url
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:title, :content, :user_id, :post_id)
  end
end
