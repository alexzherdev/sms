class Hash
  def to_json(options = {})
    ActiveSupport::JSON::encode(self, options)
  end
end