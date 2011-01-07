module Cream
  module MigrationHelper
    module CodeRefactor 

      # erase      
      def clear_relations(model_name)       
        model_name = model_name.to_s
        erase_in(model_name, has_roles_through_assignments)
        erase_in(model_name, has_roles)  
        erase_in(model_name, has_role_assignments)
      end

      def erase_in(model_name, txt)      
        model_name = model_name.to_s   
        file = File.new(model_file(model_name))
        return if !(file.read =~ /#{txt}/)         
        gsub_file model_file(model_name), /#{Regexp.escape(txt + "\n")}/, ''
      end


      # insert
      def write_model_file(model_name, content)    
        model_name = model_name.to_s
        File.open(model_file(model_name), 'w+') do |f| 
          f.write(content) 
        end
      end

      def insert_relation(model_name, relation)
        model_name = model_name.to_s
        file = File.new(model_file(model_name))
        return if (file.read =~ /#{relation}/) 
        gsub_file model_file(model_name), /class #{model.camelize} < ActiveRecord::Base/ do |match|
          match << "\n  #{relation}"
        end
      end      
        
      def remove_relation(model_name, relation)
        erase_in(model_name.to_s, relation)  
      end
      
      def belongs_to_user
        'belongs_to :user'
      end

      def belongs_to_role
        'belongs_to :role'
      end
      
      # refactor code
      def has_role_assignments 
        'has_many :role_assignments'
      end

      def has_roles_through_assignments 
        'has_many :roles, :through => :role_assignments'
      end

      def has_roles 
        'has_many :roles'
      end
        
      def role_file_content
        %Q{
  class Role < ActiveRecord::Base
  #{has_role_assignments}
  #{has_roles_through_assignments}
  end          
        }    
      end       
    
      def role_assignment_file_content
        %Q{
  class RoleAssignment < ActiveRecord::Base
#{belongs_to_user}
#{belongs_to_role}
  end          
        }
      end
    end 
  end
end