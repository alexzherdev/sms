module Utils

  module JavascriptTools
    
    #  It is a helper class that renders itself content to JSON as is,
    #  without any ', "", [, { etc -- to include JS code right into the JSON.
    class StrippedJsonString < String

      #  Returns a JSON representation of the instance. Key difference is
      #  that it doesn't add any extra symbols, just renders the content of the
      #  string right into the stream.
      def to_json(options = {})
        self.to_s
      end
      
      def to_s
        self
      end

      def encode_json(encoder)
        self
      end
    end


    #  Replaces all the keys in the given hash with +StrippedJsonString+ objects to
    #  make them correctly appear in JS as object keys.
    def strip_hash_keys_for_json(obj)
      case obj
        when Array then strip_hashes_for_json_from_array(obj)
        when Hash  then  strip_hashes_for_json_from_hash(obj)
      end

      obj
    end

    def strip_in_json(str)
      StrippedJsonString.new str
    end
    
    def delegate_in_js(str)
      StrippedJsonString.new "function() { #{str} }"
    end

    def sanitize_script_tags(str)
      strip_in_json "\"" + str.gsub("<script", '<scri" + "pt').gsub("</script>", '</scri" + "pt>') + "\""
    end

    def full_server_js_path(path)
      "/javascripts/#{(path.ends_with?(".js") ? path : path + ".js")}"
    end
    
    private

    def strip_hashes_for_json_from_array(array)
      array.each do |element|
        strip_hash_keys_for_json element
      end
    end

    def strip_hashes_for_json_from_hash(hash)
      new_hash = {}
      hash.each do |key, value|
        new_key = StrippedJsonString.new key.to_s
        value = hash[key]
        hash.delete key
        new_hash[new_key] = value

        if value.is_a?(Hash) || value.is_a?(Array)
          strip_hash_keys_for_json(value)
        end
      end
      hash.merge!(new_hash)
      hash
    end

  end

end

module JSONFix
  def self.included(base)
    base.class_eval do
      undef to_json
      def to_json(options = nil)
        ActiveSupport::JSON.encode(self, options)
      end
    end
  end
end

[
  Hash, 
  Array, 
  String, 
  Numeric, 
  TrueClass, 
  FalseClass, 
  BigDecimal
].each {|c| c.send(:include, JSONFix) }



