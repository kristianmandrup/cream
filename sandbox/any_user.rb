class Stuff
  def for_any_user options = nil, &block
    state = extract_label options

    yield if current_user.is?(:guest) && state == :logged_in
    yield if !current_user.is?(:guest) && state == :logged_out
  end

  def not_for_any_user options = nil, &block
    state = extract_label options

    return if current_user.is?(:guest) && state == :logged_in    
    return if !current_user.is?(:guest) && state == :logged_out

    yield 
  end

  def is? x
    false
  end
  
  def current_user
    Stuff.new
  end   
  
  private

  def extract_label options
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

  def logged_in_labels
    [:logged_in, :signed_in, :not_logged_out, :not_signed_out]
  end

  def logged_out_labels
    [:logged_out, :signed_out, :not_logged_in, :not_signed_in]
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
