require 'require_all'
require 'spec_helper'

require 'cream/helper/host'

describe Cream::Helper::Host do
  extend_view_with Cream::Helper::Host

  describe '#localhost?' do
    it "should return true if request.host is 'localhost'" do
      request = stub()
      request.stubs(:host).returns 'localhost'        
      
      with_engine do |e, view|
        view.stubs(:request).returns request

        res = e.run_template do 
          %{<%= localhost? %> }
        end
        res.should match /true/
      end    
    end

    it "should return true if request.host is '127.0.0.1'" do
      request = stub()
      request.stubs(:host).returns '127.0.0.1'        

      with_engine do |e, view|
        view.stubs(:request).returns request

        res = e.run_template do 
          %{<%= localhost? %> }
        end
        res.should match /true/
      end    
    end
  end

  describe '#publichost?' do
    it "should return false if request.host is 'localhost'" do
      request = stub()
      request.stubs(:host).returns 'localhost'        

      with_engine do |e, view|
        view.stubs(:request).returns request

        res = e.run_template do 
          %{<%= publichost? %> }
        end
        res.should match /false/
      end    
    end

    it "should return true if request.host is '214.353.343.222'" do
      request = stub()
      request.stubs(:host).returns '214.353.343.222'        

      with_engine do |e, view|
        view.stubs(:request).returns request

        res = e.run_template do 
          %{<%= publichost? %> }
        end
        res.should match /true/
      end    
    end
  end
end
