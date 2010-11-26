require 'spec_helper'
require 'cream/helper/role'

describe Cream::Helper::Role do
  
  extend_view_with Cream::Helper::Role  

  context 'method auto-generated when Rails initialize based on registered roles' do
    describe '#guest_area' do              

      # it "should execute an Admin guarded block for :admin" do        
      #   view_engine do |e, view|
      #     view.stubs(:has_role?).with([:admin]).returns true
      # 
      #     res = e.run_template do 
      #       %{<%= for_admin { 'hello' } %>}
      #     end        
      #     res.should match /hello/
      #   end
      # end
      #   
      # it "should not execute an Admin guarded block for user not :admin" do        
      #   view_engine do |e, view|
      #     view.stubs(:has_role?).with([:admin]).returns false
      # 
      #     res = e.run_template do 
      #       %{<%= for_admin { 'hello' } %>}
      #     end        
      #     res.should be_empty
      #   end
      # end
    end # desc
  end # context

  context 'admin user' do  
    describe '#for_roles' do                    
      it "display an :admin only block" do        
        view_engine do |e, view|
          view.stubs(:has_role?).with([:admin]).returns true

          res = e.run_template do 
            %{<%= for_roles(:admin) { 'hello' } %>}
          end
          res.should match /hello/
        end
      end
      
      it "should not display a :guest only block" do
        view_engine do |e, view|
          view.stubs(:has_role?).with([:guest]).returns false

          res = e.run_template do 
            %{<%= for_roles(:guest) { 'hello' } %>}
          end        
          res.should be_empty
        end
      end
    end # desc  
  
    describe '#not_for_roles' do              
      it "should not display a block not for :admin" do        
        view_engine do |e, view|
          view.stubs(:has_role?).with([:admin]).returns true

          res = e.run_template do 
            %{<%= not_for_roles(:admin) { 'hello' } %>}
          end        
          res.should be_empty
        end
      end
    
      it "should display a div block not for :guest" do        
        view_engine do |e, view|
          view.stubs(:has_role?).with([:guest]).returns false

          res = e.run_template do 
            %{<%= not_for_roles(:guest) { 'hello' } %>}
          end        
          res.should match /hello/
        end
      end
    end # desc
  end
  
  describe '#has_role?' do
    context 'user has role :admin' do
      it "should make has_role? :admin be true" do
        user = stub()
        user.stubs(:has_role?).with([:admin]).returns true

        view_engine do |e, view|
          view.stubs(:current_user).returns user

          res = e.run_template do 
            %{<%= has_role?(:admin) %> }
          end
          res.should match /true/
        end    
      end

      it "should make has_role? :guest be false" do
        user = stub()
        user.stubs(:has_role?).with([:guest]).returns false

        view_engine do |e, view|
          view.stubs(:current_user).returns user
          res = e.run_template do 
            %{<%= has_role?(:guest) %> }
          end
          res.should match /false/
        end    
      end
    end # ctx
  end # dec

  describe '#has_roles?' do
    context 'user has roles :admin and :guest' do
      it "should make has_roles? :admin, :guest be true" do
        user = stub()
        user.stubs(:has_roles?).with([:admin, :guest]).returns true

        view_engine do |e, view|
          view.stubs(:current_user).returns user
          res = e.run_template do 
            %{<%= has_roles?(:admin, :guest) %> }
          end
          res.should match /true/
        end    
      end

      it "should make has_role? :unknown, :guest be false" do
        user = stub()
        user.stubs(:has_roles?).with([:unknown, :guest]).returns false

        view_engine do |e, view|
          view.stubs(:current_user).returns user
          res = e.run_template do 
            %{<%= has_roles?(:unknown, :guest) %> }
          end
          res.should match /false/
        end    
      end
    end # ctx
  end
  
  describe '#owner?' do
    it "should return false, since the user is NOT the owner of the post, but an other user" do
      user = stub()
      other_user = stub()
      view_engine do |e, view|
        view.stubs(:current_user).returns user
        @post.stubs(:owner).returns other_user
        
        res = e.run_template_locals :post => @post do 
          %{<%= owner?(post) %> }
        end
        res.should match /false/
      end    
    end

    it "should return true, since the user is the owner of the post (default :owner relation)" do
      user = stub()
      view_engine do |e, view|
        view.stubs(:current_user).returns user
        @post.stubs(:owner).returns user
        
        res = e.run_template_locals :post => @post do 
          %{<%= owner?(post) %> }
        end
        res.should match /true/
      end    
    end

    it "should return true, since the user is the owner of the post using custom ownership relation :maker" do
      user = stub()
      view_engine do |e, view|
        view.stubs(:current_user).returns user
        @post.stubs(:maker).returns user
        
        res = e.run_template_locals :post => @post do 
          %{<%= owner?(post, :maker) %> }
        end
        res.should match /true/
      end    
    end
  end # desc 
end
