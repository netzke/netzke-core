class NetzkeController < ApplicationController
  include Netzke::Railz::ControllerExtensions

  skip_before_action :verify_authenticity_token, only: [:ext, :direct, :dispatcher]
end
