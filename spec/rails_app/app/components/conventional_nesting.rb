class ConventionalNesting < Netzke::Base
  js_configure do |c|
    c.layout = :hbox
  end

  component :simple_panel_one do |c|
    c.klass = SimplePanel
    c.flex = 1
    c.title = 'One'
    c.height = '100%'
  end

  component :simple_panel_two do |c|
    c.klass = SimplePanel
    c.flex = 4
    c.title = 'Two'
    c.height = '100%'
  end

  def configure(c)
    super
    c.items = [
      {flex: 1, title: "Panel", items: [:simple_panel_one]},
      # :simple_panel_one,
      :simple_panel_two
      # {
      #   flex: 4,
      #   title: 'Two',
      #   klass: SimplePanel,
      #   height: '100%',
      #   layout: :vbox,
      #   defaults: {
      #     width: "100%"
      #   },
      #   items: [{
      #     klass: SimplePanel,
      #     title: 'Two One',
      #     flex: 1
      #   }, {
      #     klass: Endpoints,
      #     title: 'Two Two',
      #     flex: 1
      #   }]
      # }
    ]
  end
end
