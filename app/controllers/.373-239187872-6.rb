# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '7756e2ed6d15ae9796d653f265b5ca82'

  WEBLAYOUT = "layout_3"


  def authorize
    unless session[:admin_id]
      flash[:notice] = "Please log in."
      redirect_to(:controller => "login", :action => "login")
    else
      begin
        admin = Admin.find(session[:admin_id])
        unless admin and (admin.has_permission?(self.class.to_s))
          flash[:notice] = "You don't have permission to access that area."
          redirect_to(:controller => "login", :action => 'home')
        end
      rescue ActiveRecord::RecordNotFound
        session[:admin_id] = nil
        flash[:notice] = "You have been unexpectedly logged off. Sorry."
        redirect_to(:controller => 'login', :action => 'login')
      end
    end
  end

  def get_content_page
    @content_page = ContentPage.find_by_url(params[:controller], params[:action])
    @web_layout = WEBLAYOUT
  end

  def random_string(n=6)
    out = []
    for i in 0..n
      out << (65 + rand(26) + (32 * rand(2))).chr
    end
    out.to_s
  end

  def update_current_admin
    Admin.current = session[:admin_id]
  end

end
