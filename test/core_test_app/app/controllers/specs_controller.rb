require 'coffee-script'

# Compiles coffeescript specs to javascripts on the fly
class SpecsController < ApplicationController
  def show
    path = params[:id].gsub("__", "/")
    coffee_script = File.read(File.expand_path("../../../../../spec/javascripts/#{path}.js.coffee", __FILE__))
    render text: CoffeeScript.compile(coffee_script)
  end
end
