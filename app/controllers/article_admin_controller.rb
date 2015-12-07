class ArticleAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end

  def list
    @list_name = :article_admin_list
    update_session
    @articles, @article_pages = Article.paginate_and_order(session[@list_name])
  end

  def update_session
    unless session[@list_name]
      session[@list_name] = {}
    end
    [:page, :order_direction, :order_field, :search].each do |param|
      if params[param]
        session[@list_name][param] = params[param]
      end
    end
    session[@list_name][:order_direction] = "asc"
    session[@list_name][:order_field] = "id"
  end


  def new
    if request.get?
      @article = Article.new
    else
      @article = Article.new(params[:article])
      if @article.save
        flash[:notice] = "The article was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that article."
        flash[:error_field] = :article
      end
    end
  end

  def edit

    @article = Article.find(params[:id])
    if request.post?
      if @article.update_attributes(params[:article])
        flash[:notice] = "The article was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that article."
        flash[:error_field] = :article
      end
    end
  end

  def delete
    @article = Article.find(params[:id])
    if @article.destroy
      flash[:notice] = "That article was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that article."
    end
    redirect_to :action => 'list'
  end


end
