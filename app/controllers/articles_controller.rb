class ArticlesController < ApplicationController
  before_action :authenticate_admin!, except: [:index, :show]
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @era_list = Article
    unless user_signed_in?
      @era_list = @era_list.where(public: true)
    end
    @era_list = @era_list.distinct.order(era: :desc).pluck(:era)
    if params[:era] == nil
      now_era = @era_list[0]
    else
      now_era = params[:era].to_i
    end

    @articles = Article.where(era: now_era, category: 0).order(pinned: :desc, id: :desc)
    @courses = Article.where(era: now_era, category: 1).order(pinned: :desc, id: :desc)
    unless user_signed_in?
      @articles = @articles.where(public: true)
      @courses = @courses.where(public: true)
    end
    @articles = @articles.includes(:user)
    @courses = @courses.includes(:user)
    @era = now_era.to_s
  end

  def show
  end

  def create
    @article = Article.new(article_params)
    @article.user_id = current_user.id
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
  end

  def edit
  end

  def update
    @article.user_id= current_user.id
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: 'Article was successfully updated.' }
      else
        format.html { render action: 'edit' }
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
