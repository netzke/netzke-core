module Netzke
  module BaseExtras
    module Interface
      def get_widget(params = {})
        # if browser does not have our component class cached (and all dependencies), send it to him
        components_cache = (JSON.parse(params[:components_cache]) if params[:components_cache]) || []
        {:config => js_config, :class_definition => js_missing_code(components_cache)}
      end
    end
  end
end