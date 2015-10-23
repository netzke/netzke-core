# For demo purposes. Not used in testing.
class SimpleAuthenticationComponent < Netzke::Base
  action :sign_in

  action :sign_out

  def configure(c)
    super
    c.tbar = signed_in? ? [current_user_info, "->", :sign_out] : ["->", :sign_in]
  end

  client_class do |c|
    c.on_sign_in = <<-JS
      function(){
        this.signIn();
      }
    JS

    c.on_sign_out = <<-JS
      function(){
        this.signOut();
      }
    JS

    c.reload_page = <<-JS
      function(){window.location = window.location;}
    JS
  end

  endpoint :sign_in do |params,this|
    session[:user_id] = 1
    this.reload_page
  end

  endpoint :sign_out do |params,this|
    session.delete(:user_id)
    this.reload_page
  end

  def current_user_info
    session[:user_id] && "Signed in as user#: #{session[:user_id]}" || ""
  end

  def signed_in?
    !!session[:user_id]
  end
end
