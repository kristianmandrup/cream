module Cream::View
  module Host
    def for_localhost(&block)
      yield block if localhost?
    end  

    def for_public(&block)
      # with_output_buffer(&block) if publichost?
      yield block if publichost?
    end  
  end
end