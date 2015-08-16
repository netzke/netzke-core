module ExtDirect
  class Details < Netzke::Base
    endpoint :update do
      this.set_title title
    end

    def title
      "Details for user #{config[:user]}"
    end
  end
end
