module ExtDirect
  class Details < Netzke::Base
    endpoint :update do |params, this|
      this.set_title title
    end

    def title
      "Details for user #{config[:user]}"
    end
  end
end
