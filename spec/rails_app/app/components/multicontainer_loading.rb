class MulticontainerLoading < Netzke::Base
  client_class do |c|
    c.layout = :hbox
  end

  action :replace_tab_in_left
  action :load_in_right

  def configure(c)
    super

    c.items = [
      {
        item_id: 'left', flex: 1, height: "100%", title: 'Left', xtype: 'tabpanel',
        items: [
          { title: 'One', item_id: 'one' }, { title: 'Two' }
        ]
      },
      {
        item_id: 'right', flex: 1, height: "100%", title: 'Right', layout: :fit,
        items: []
      }
    ]

    c.bbar = [:replace_tab_in_left, :load_in_right]
  end

  component :hello_user
end
