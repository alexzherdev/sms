module ActiveSupport
  class BufferedLogger
    def flush
      @guard.synchronize do
        unless buffer.empty?
          if defined? Encoding
            old_buffer = buffer.map { |b| (b.encoding == Encoding::ASCII_8BIT)? b.force_encoding(Encoding::UTF_8).encode : b }
          else
            old_buffer = buffer
          end
          @log.write(old_buffer.join)
        end
        # Important to do this even if buffer was empty or else @buffer will
        # accumulate empty arrays for each request where nothing was logged.
        clear_buffer
      end
    end    
  end
end