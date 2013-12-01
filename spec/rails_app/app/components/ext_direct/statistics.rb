module ExtDirect
  class Statistics < Netzke::Base
    endpoint :update do |params, this|
      this.set_title title
    end

    def title
      "Statistics for user #{config[:user]}"
    end
  end
end
