module ActiveSupport
  class TimeWithZone
    def to_json(options = {})
      self.to_s(:db).to_json
    end
  end
end