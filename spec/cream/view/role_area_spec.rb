require 'rspec-action_view'
require 'require_all'
require 'spec_helper'

require 'cream/namespaces'
require 'cream/view/role_area'
require 'cream/view/host_area'

describe Cream::View::Role do
  extend_view_with Cream::View, :role, :host
  
  describe '#area' do
    it "should display the div with hello" do
      with_engine do |e, view|

        res = e.run_template do 
          %{<%= area :class => 'red' do %>
              hello
           <% end %>}
        end
        res.should match /<div class="red">/
        res.should match /hello/
      end
    end

    it "should display the div with hello when localhost block nested inside" do
      with_engine do |e, view|
        view.stubs(:localhost?).returns true
        
        res = e.run_template do 
          %{<%= area :class => 'red' do %>
              <%= for_localhost { 'hello' } %>
           <% end %>}
        end
        res.should match /<div class="red">/
        res.should match /hello/
      end
    end

    it "should display the div with hello when nested within localhost block" do
      with_engine do |e, view|
        view.stubs(:localhost?).returns true
        
        res = e.run_template do 
          %{<%= for_localhost do %>
              <%= area :class => 'red' do %>              
                hello
              <% end %>  
           <% end %>
          }
        end
        res.should match /<div class="red">/
        res.should match /hello/
      end
    end
  end
  
  describe '#area_for_roles' do              
    it "should display an area for :admin" do        
      with_engine do |e, view|
        view.stubs(:has_role?).with([:admin]).returns true

        res = e.run_template do 
          %{<%= area_for_roles(:admin) { 'hello' } %>}
        end        
        res.should match /hello/
      end
    end
  
    it "should not display an area for user not :admin" do        
      with_engine do |e, view|
        view.stubs(:has_role?).with([:admin]).returns false

        res = e.run_template do 
          %{<%= area_for_roles(:admin) { 'hello' } %>}
        end        
        res.should be_empty
      end
    end
  end # desc 

  describe '#area_not_for_roles' do              
    it "should not display an area for user :admin" do        
      with_action_view do |view|      
        view.stubs(:has_role?).with([:admin]).returns true
        view.area_not_for_roles(:admin) { 'hello' }.should be_nil
      end    
    end
  
    it "should display an area for user not :admin" do        
      with_action_view do |view|  
        # he is not admin    
        view.stubs(:has_role?).with([:admin]).returns false
        view.area_not_for_roles(:admin) { 'hello' }.should match /hello/
      end    
    end                
  end # desc

  context 'method auto-generated when Rails initialize based on registered roles'
    describe '#guest_area' do              
      it "should display an Admin area for :admin" do        
        with_engine do |e, view|
          view.stubs(:has_role?).with([:admin]).returns true

          res = e.run_template do 
            %{<%= admin_area { 'hello' } %>}
          end        
          res.should match /hello/
        end
      end
  
      it "should not display a Admin area for user not :admin" do        
        with_engine do |e, view|
          view.stubs(:has_role?).with([:admin]).returns false

          res = e.run_template do 
            %{<%= admin_area { 'hello' } %>}
          end        
          res.should be_empty
        end
      end
    end # desc
  end # context  
end