class WelcomeController < ApplicationController
  def index
    render :text => "This is a test app built into netzke_core"
  end
end