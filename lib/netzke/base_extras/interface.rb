module Netzke
  module BaseExtras
    module Interface
      def get_widget(params = {})
        components_cache = (JSON.parse(params[:components_cache]) if params[:components_cache]) || []

        js = js_missing_code(components_cache)
        css = css_missing_code(components_cache)

        css = nil if css.blank?

        # if browser does not have our widget's (and all its dependencies') class and styles, send it over
        { :config => js_config, 
          :js => js,
          :css => css
        }
      end
    end
  end
end