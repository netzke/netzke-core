# This component shares state with StatefulComponent by setting +persistence_key+ to that component's js_id (which is used as persestence_key by default)
class StatefulComponentWithSharedState < Netzke::Base
  def configure(c)
    super
    c.persistence = true
    c.persistence_key = :stateful_component

    # title will be gotten from component's state
    c.title = state[:title] || "Default Title"
  end
end
