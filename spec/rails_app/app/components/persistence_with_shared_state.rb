# This component shares state with StatefulComponent by setting +persistence_key+ to that component's js_id (which is used as persestence_key by default)
class PersistenceWithSharedState < Persistence
  def configure(c)
    c.persistence_key = :persistence
    super
  end
end
