module Cream
  module GeneratorHelper
    module Orm 
      def validate_orm
         if !valid_orms.include?(orm)
           say "ERROR: ORM #{orm} is not currently supported. Please use one of: #{valid_orms_list}", :red
           return false
         end
         true
      end
      
      def orm
        @orm ||= get_orm options[:orm].to_s.underscore.to_sym
      end

      def valid_orms_list
        valid_orms.map(&:to_s).join(', ')
      end

      def valid_orms
        active_record + data_mapper + mongo_mapper + [:couch_db, :mongoid]
      end

      def active_record
        [:ar, :active_record]
      end

      def is_active_record? name 
        active_record.include? name
      end

      def mongo_mapper
        [:mm, :mongo_mapper]
      end

      def is_mongo_mapper? name 
        mongo_mapper.include? name
      end

      def data_mapper
        [:dm, :data_mapper]
      end

      def is_data_mapper? name 
        data_mapper.include? name
      end

      def get_orm name
        return :active_record if is_active_record? name 
        return :mongo_mapper if is_mongo_mapper? name
        return :data_mapper if is_data_mapper? name

        return :couch_db  if orm_name == :couch_db
        return :mongoid   if orm_name == :mongoid
        
        raise ArgumentError, "ERROR: Cream does not currently support the orm: #{name}"
      end
    end
  end
end