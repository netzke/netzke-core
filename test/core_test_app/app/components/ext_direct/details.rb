module ExtDirect
  class Details < Netzke::Base
    js_property :padding, 5

    endpoint :update do |params|
      {:set_title => title}
    end

    def title
      "Details for user #{config[:user]}"
    end
  end
end
