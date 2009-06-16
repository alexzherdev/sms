String.class_eval do
  def j
    Utils::JavascriptTools::StrippedJsonString.new self
  end
end