# TODO: 
# model_file_name and similar methods in rails3_assist and rails3_artifaftor should be fixed to always call underscore on filenames

class String
  def as_filename
    self.underscore  
  end
end

class Symbol
  def as_filename
    self.to_s.underscore  
  end
end
