module Netzke
  # Netzke component allows specifying Ext actions.
  # An action can be defined in 2 different ways, both of which result in a method definition like this
  #     def _<some_action>_action
  #       ...
  #     end
  #
  # The 2 ways to define an action are:
  # * as a hash:
  #     action :bug_server, :text => "Call server", :icon => "/images/icons/phone.png"
  #
  # * as a block:
  #     action :bug_server do
  #       {:text => config[:text], :disabled => true}
  #     end
  #
  # The block can optionally receive the configuration of an action being overridden:
  #     action :bug_server do |orig|
  #       {:text => config[:text] + orig[:text], :disabled => orig[:disabled]}
  #     end
  module Actions
    extend ActiveSupport::Concern

    ACTION_METHOD_NAME = "%s_action"
    ACTION_METHOD_REGEXP = /^(.+)_action$/

    included do
      alias_method_chain :js_config, :actions
    end

    module ClassMethods
      def action(name, config = {}, &block)
        config[:name] = name.to_s
        method_name = ACTION_METHOD_NAME % name

        if block_given?
          define_method(method_name, &block)
        else
          if superclass.instance_methods.map(&:to_s).include?(method_name)
            define_method(method_name) do
              super().merge(config)
            end
          else
            define_method(method_name) do
              config
            end
          end
        end
      end
    end

    # Actions to be used in the config
    def actions
      # Call all the action related methods to collect the actions
      self.class.instance_methods.grep(ACTION_METHOD_REGEXP).inject({}) do |r, m|
        m.match(ACTION_METHOD_REGEXP)
        r.merge($1.to_sym => normalize_action_config(send(m)))
      end
    end

    def js_config_with_actions #:nodoc
      actions.empty? ? js_config_without_actions : js_config_without_actions.merge(:actions => actions)
    end

    private
      def normalize_action_config(config)
        if config[:icon].is_a?(Symbol)
          config[:icon] = Netzke::Core.with_icons ? Netzke::Core.icons_uri + "/" + config[:icon].to_s + ".png" : nil
        end

        config[:text] ||= config[:name].humanize

        config
      end

      def auto_collect_actions_from_config_and_js_properties
        # res = extract_actions(js_properties)
        # puts %Q(!!! res: #{res.inspect}\n)
      end

      # def extract_actions(hsh)
      #   hsh.each_pair.inject({}) do |r,(k,v)|
      #     v.is_a?(Array) ? r.merge(extract_actions_from_array(v)) : r
      #   end
      # end
      #
      # def extract_actions_from_array(arry)
      #   arry.inject({}) do |r, el|
      #     if el.is_a?(Hash)
      #       el[:action] ? r.merge(el[:action] => default_action_config(el[:action])) : r.merge(extract_actions(el))
      #     else
      #       r
      #     end
      #   end
      # end
      #
      # def default_action_config(action_name)
      #   {:text => action_name.to_s.humanize}
      # end

  end
end