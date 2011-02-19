module Cream
  module GeneratorHelper
    module Strategy 
      def validate_strategy
         if !valid_strategies.include?(strategy.to_sym)
           say "ERROR: Strategy '#{strategy}' is not currently supported by Cream. Please use one of: #{valid_strategies_list}", :red
           return false
         end
         true
      end

      def valid_strategies_list
        valid_strategies.map(&:to_s).join(', ')
      end

      def valid_strategies
        @strategies ||= begin
          s = basic_strategies          
          s |= document_store_strategies if document_store?
          s.flatten
        end
      end

      def role_ref_strategy?
        role_ref_strategies.include? strategy
      end

      def embed_strategy?
        role_embed_strategies.include? strategy
      end

      def document_store_strategy?
        document_store_strategies.include? strategy
      end

      def inline_strategy?
        document_store_strategies.include? strategy
      end

      def role_ref_strategies
        [:one_role, :many_roles]
      end

      def role_embed_strategies
        [:embed_one_role, :embed_many_roles]
      end

      def inline_strategies
        valid_strategies - role_ref_strategies - role_embed_strategies
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
