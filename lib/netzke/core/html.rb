module Netzke
  module Core
    # Provides support for HTML rendering (currently HAML only)
    module Html
      # Will render an HTML template found in +{component_location}/html/+ For example:
      #
      #     class MyComponent < Netzke::Base
      #       def configure_client(c)
      #         super
      #         c.html = render(:body)
      #       end
      #     end
      #
      # This will render the HAML file located in +app/components/my_component/html/body.html.haml
      # The implementation is very simplistic at the moment - e.g. no caching, no support for .erb
      def render(what)
        callr = caller.first
        engine = Haml::Engine.new(File.read(expand_html_path(what, callr)))
        engine.method(:render).call(self)
      end

    private

      def expand_html_path(sym, callr = nil)
        %Q(#{callr.split(".rb:").first}/html/#{sym}.html.haml)
      end
    end
  end
end
