class CommentsController < ApplicationController
  include PostFilteringConcern

  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  before_action :find_post
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :check_contest_and_problem
  before_action :check_post_create, only: [:new, :create]
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
        if @postable
          target = [@postable, @post, @comment]
        else
          target = [@post, @comment]
        end
        format.html { redirect_to @page_path, notice: 'Comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: polymorphic_path(target) }
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

  def check_post_create
    check_problem_allow_create
    # disable comment on contests
    unless user_signed_in? and current_user.admin?
      if @contest
        redirect_to contest_posts_path(@contest), :alert => "Comments not allowed in contest."
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

  def set_comment_object
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  def find_post
    filter_posts
    @post = @posts.find(params[:post_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def comment_params
    params.require(:comment).permit(:title, :content, :user_id, :post_id)
  end
end
