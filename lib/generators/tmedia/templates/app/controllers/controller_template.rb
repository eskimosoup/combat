class <%= class_name %>Controller < ApplicationController

  layout "web"

  def index
    redirect_to :action => 'list'
  end

  def list
    @<%= file_name.pluralize %>, @<%= file_name %>_pages = <%= class_name %>.paginate_and_order(params)
  end

  def show
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

end
