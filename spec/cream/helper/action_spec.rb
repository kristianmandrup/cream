require 'spec_helper'
require 'cream/helper/action'
require 'cream/configure/rails'


describe Cream::Helper::Action do
  
  extend_view_with Cream::Helper::Action

    describe '#user_can?' do              
      it "should execute guarded block since the user has permission to edit his project" do
        view_engine do |e, view|          
          current_user = User.new 'me'
          project = Project.new 'mine', :author => current_user
          
          # add vars to view
          
          view.stubs(:user_can?).with([:edit, project]).returns true
      
          res = e.run_template do 
            %{<%= user_can?(:edit, my_project) { 'hello' } %>}
          end        
          res.should match /hello/
        end
      end
        
      it "should not execute guarded block for user who has no permission to edit another project" do
        view_engine do |e, view|

          current_user = User.new 'me'
          other_user = User.new 'him'
          project = Project.new 'other', :author => other_user
          
          # add vars to view

          view.stubs(:user_can?).with([:edit, his_project]).returns false
      
          res = e.run_template do 
            %{<%= user_can?(:edit, his_project) { 'hello' } %>}
          end        
          res.should be_empty
        end
      end
    end # desc
  end # context
