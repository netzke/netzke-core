require 'coffee-script'

# Compiles coffeescript specs on the fly
class SpecsController < ApplicationController
  def show
    spec_path = params[:id].gsub("__", "/")
    path = "../../../../../spec/mocha/#{spec_path}.js.coffee"
    coffee = File.read(File.expand_path(path, __FILE__))
    render text: CoffeeScript.compile(coffee)
  end
end
