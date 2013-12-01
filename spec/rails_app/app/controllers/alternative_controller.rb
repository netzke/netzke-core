# Controller that can be configured in config/routes.rb to be used as NetzkeController, i.e. for processing endpoint calls. All it does is respond to any endpoint call with the same response.
class AlternativeController < ActionController::Base
  include Netzke::Railz::ControllerExtensions

  before_filter :do_static_endpoint_response, only: :direct

  def do_static_endpoint_response
    render text: direct_response(params, {netzke_feedback: ["Hit AlternativeController's before filter"]}).to_json
  end
end
