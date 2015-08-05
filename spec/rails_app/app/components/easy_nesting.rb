class EasyNesting < Netzke::Base
  js_configure do |c|
    c.layout = :hbox
  end

  def configure(c)
    super
    c.items = [
      {
        flex: 1,
        title: 'One',
        class_name: 'SimplePanel',
        height: '100%'
      },

      {
        flex: 4,
        title: 'Two',
        class_name: 'SimplePanel',
        height: '100%',
        layout: :vbox,
        defaults: {
          width: "100%"
        },
        items: [{
          class_name: 'SimplePanel',
          title: 'Two One',
          flex: 1
        }, {
          class_name: 'Actions',
          title: 'Two Two',
          flex: 1
        }]
      }
    ]
  end
end
