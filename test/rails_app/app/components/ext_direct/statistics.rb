module ExtDirect
  class Statistics < Netzke::Base
    js_property :padding, 5

    endpoint :update do |params|
      {:set_title => title}
    end

    def title
      "Statistics for user #{config[:user]}"
    end
  end
end
