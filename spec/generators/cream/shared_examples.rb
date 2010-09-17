it "should generate Permits for Guest and Admin roles"
  @generator.should generate_permits :guest, :admin
end

it "should generate Permits for Guest and Admin roles"
  @generator.should generate_permits :guest, :admin
end 


it "should inject permission exception handling into controller 'application_controller'"
  @generator.should update_controller :application do |clazz|
    clazz.should match /rescue_from CanCan::AccessDenied/
  end
end 

it "should generate 'cream' locale file"
  @generator.should generate_locale_file :cream
end 
