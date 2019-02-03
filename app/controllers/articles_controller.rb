class ArticlesController < ApplicationController
  before_action :authenticate_admin!, except: [:index, :show]
  before_action :set_article, only: [:show, :edit, :update, :destroy]
  
  def index
    if user_signed_in?
      @articles = Article.where("category = 0 AND pinned = true AND era = ?", get_era).order("id DESC")
      @articles += Article.where("category = 0 AND pinned != true AND era = ?", get_era).order("id DESC")
      @courses = Article.where("category = 1 AND pinned = true AND era = ?", get_era).order("id DESC")
      @courses += Article.where("category = 1 AND pinned != true AND era = ?", get_era).order("id DESC")
    else
      @articles = Article.where("category = 0 AND pinned = true AND era = ? AND public = true", get_era).order("id DESC")
      @articles += Article.where("category = 0 AND pinned != true AND era = ? AND public = true", get_era).order("id DESC")
      @courses = Article.where("category = 1 AND pinned = true AND era = ? AND public = true", get_era).order("id DESC")
      @courses += Article.where("category = 1 AND pinned != true AND era = ? AND public = true", get_era).order("id DESC")
    end
      
    @era = get_era.to_s
    set_page_title "Bulletin - " + @era
  end
  
  def show
    set_page_title @article.title
  end
  
  def create
    @article = Article.new(article_params)
    @article.author_id = current_user.id
    @article.era = get_era

    respond_to do |format|
      if @article.save
        format.html { redirect_to @article, notice: 'Article was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end
  
  def new
    @article = Article.new
    set_page_title "New article"
  end
  
  def edit
    set_page_title "Edit - " + @article.title
  end
  
  def update
    @article.author_id = current_user.id
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
      else
        format.html { render action: 'new' }
      end
    end
  end
  
  def destroy
    @article.destroy
    redirect_to articles_path
  end
  
private

  def get_era
    if params[:era] == nil
      return Time.now.year
    else
      return params[:era].to_i
    end
  end

  def set_article
    @article = Article.find(params[:id])
    if not @article.public and not user_signed_in?
      redirect_to root_path, alert: 'Please login to view this article.'
    end
  end
  
  def article_params
    params.require(:article).permit(
      :id,
      :title,
      :content,
      :pinned,
      :category,
      :public,
      attachments_attributes:
      [
        :id,
        :path,
        :_destroy
      ]
    )
  end
end
