class KindaComplexComponent < Netzke::Base
  module ExtraStuff
    # Let's add another tab with a Netzke component in it
    def config
      orig = super
      orig[:items] << {:class_name => "ServerCaller"}
      orig
    end
  end
end