class EndpointsExtended < Endpoints
  def configure(c)
    super
    c.title = "Endpoints Extended"
  end

  action :with_response do |c|
    c.text = "With extended response"
  end

  # Overriding the :whats_up endpoint from ServerCaller
  endpoint :whats_up do |greeting|
    super greeting

    client.set_title(client.set_title[0] + " plus")
  end
end
