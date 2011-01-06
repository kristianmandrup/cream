class Stuff
  def for_any_user options = nil, &block
    yield if Labels.state_check Labels.extract(options), current_user
  end

  def not_for_any_user options = nil, &block
    return if Labels.state_check Labels.extract(options), current_user
    yield 
  end

  def is? x
    false
  end
  
  def current_user
    nil # Stuff.new
  end   
  
  private

  module Labels    
    class << self
      def extract options
        case options
        when Symbol
          return :logged_in if logged_in_labels.include?(options)
          return :logged_out if logged_out_labels.include?(options)
        when Hash
          return :logged_in if logged_in_labels.any? {|lab| options[lab] }
          return :logged_out if logged_out_labels.any? {|lab| options[lab] }    
        end    
        raise ArgumentException, "Unknown option #{options}"
      end

      def state_check state, current_user
        logged_in_check(state, current_user) || logged_out_check(state, current_user)
      end

      def logged_in_check state, current_user
        state == :logged_in && current_user && current_user.is?(:guest)
      end

      def logged_out_check state, current_user
        state == :logged_out && (!current_user || current_user && !current_user.is?(:guest))
      end

      def logged_in_labels
        [:logged_in, :signed_in, :not_logged_out, :not_signed_out]
      end

      def logged_out_labels
        [:logged_out, :signed_out, :not_logged_in, :not_signed_in]
      end  
    end
  end
end  

s = Stuff.new

s.for_any_user :logged_in do
  puts "log out - for_any_user :logged_in"
end

s.for_any_user :logged_out do
  puts "log in - for_any_user :logged_out"
end

s.for_any_user :not_logged_in do
  puts "log in - for_any_user :not_logged_in"
end

s.for_any_user :not_logged_out do
  puts "log out - for_any_user :not_logged_out"
end

s.not_for_any_user :logged_in do
  puts "log in - not_for_any_user :logged_in"
end

s.not_for_any_user :logged_out do
  puts "log out - not_for_any_user :logged_out"
end

s.not_for_any_user :not_logged_in do
  puts "log out - not_for_any_user :not_logged_in"
end

s.not_for_any_user :not_logged_out do
  puts "log in - not_for_any_user :not_logged_out"
end
