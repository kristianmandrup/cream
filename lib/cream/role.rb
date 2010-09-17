module AuthAssistant
  module Role
    def self.available
      ::Role.all.map(&:name).to_symbols
    end
  end
end