class ArticleController < ApplicationController

  layout WEBLAYOUT

  def index
    session[:tag] = nil
    session[:month] = nil
    redirect_to :action => 'list'
  end

  def list
    init_navigation
    session[:tag] = params[:tag] if params[:tag]
    if params[:month]
      session[:month] = params[:month]
      session[:tag] = nil
    end
    if session[:tag]
      @articles = Article.find_displayable_tagged(session[:tag], :order => 'article_date desc')
      @list_name = session[:tag].humanize
    else
      if session[:month]
        params[:year] ||= Date.today.year
        @articles = Article.all_from_date(session[:month].to_i + 1, params[:year])
      else
        @articles = Article.find_recent(10)
        @list_name = ""
      end
    end
    @articles, @article_pages = Pager.pages(@articles, params[:page] || 1, 10)
  end

  def show
    @article = Article.find(params[:id])
    params[:year] = @article.article_date.year
    init_navigation
  end

  def init_year
    @months = []
    @year = params[:year].to_i || Date.today.year
    last = 12
    last = Date.today.month unless @year != Date.today.year
    for month in (0 ... last)
      @months << [month, Article.count(:conditions => ["month(article_date) = ? and year(article_date) = ?", month + 1, @year])]
    end
    @months.reverse!
  end

  def ajax_year
    init_year
    render(:layout => false)
  end

  def init_navigation
    @tags = Article.all_tags_array.sort
    init_year
    @years = []
    earliest = Article.displayable(:order => "article_date asc").first
    if earliest
      first_year = earliest.article_date.year
      for year in (first_year .. Date.today.year)
        @years << year
      end
      @years.reverse!
    end
  end

end
