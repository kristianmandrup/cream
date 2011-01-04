module Cream
  module GeneratorHelper
    module Strategy 
      def validate_strategy
         if !valid_strategies.include?(strategy)
           say "ERROR: Strategy '#{strategy}' is not currently supported by Cream. Please use one of: #{valid_strategies_list}", :red
           return false
         end
         true
      end

      def valid_strategies_list
        valid_strategies.map(&:to_s).join(', ')
      end

      def valid_strategies
        @strategies ||= basic_strategies
        @strategies << document_store_strategies if document_store?
        @strategies
      end
      
      def basic_strategies
        [:admin_flag, :role_string, :one_role, :many_roles, :roles_mask, :roles_string]
      end
      
      def document_store_strategies 
        [:embed_one_role, :embed_many_roles, :role_strings]
      end
    end
  end
end
