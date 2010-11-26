require 'spec_helper'
require 'cream/view/host_area'

describe Cream::View::Host do
  extend_view_with Cream::View::Host

  before do
    @post = stub(:title => 'my post', :id => 1, :author => 'kristian' )
  end
  
  describe '#for_localhost' do
    it "should display localhost guarded content for localhost browser agent" do
      view_engine do |e, view|
        view.stubs(:localhost?).returns true

        res = e.run_template do 
          %{<%= for_localhost do %>
              hello
            <% end %>
          }
        end
        res.should match /hello/  
      end
    end

    it "should NOT display localhost guarded content for NON-localhost browser agent" do
      view_engine do |e, view|
        view.stubs(:localhost?).returns false
    
        res = e.run_template do 
          %{<%= for_localhost { 'hello' } %>}
        end
        res.should be_empty
      end
    end
  end

  describe '#for_public' do
    it "should display public content for public browser agent" do
      view_engine do |e, view|
        view.stubs(:publichost?).returns true
  
        res = e.run_template do 
          %{<%= for_public { 'hello' } %>}
        end
        res.should match /hello/
      end
    end
  
    it "should display public content for public browser agent" do
      view_engine do |e, view|
        view.stubs(:publichost?).returns false
    
        res = e.run_template do 
          %{<%= for_public { 'hello' } %>}
        end
        res.should be_empty
      end
    end
  end  
end