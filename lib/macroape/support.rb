module Kernel
  def type_cast(new_class, &block)
    new_obj = new_class.allocate  
    instance_variables.each do |varname|
      new_obj.instance_variable_set(varname, self.instance_variable_get(varname))
    end
    new_obj.instance_eval(&block) if block_given?
    new_obj
  end
  
  def depth_dup
    begin
      new_obj = self.dup
    rescue
      return self
    end
    new_obj.instance_variables.each do |varname|
      begin
        new_obj.instance_variable_set(varname, new_obj.instance_variable_get(varname).depth_dup)
      rescue
      end
    end
    new_obj
  end
  
end

def File.filename_wo_ext(filename)
  filename[0..-(1+File.extname(filename).length)]
end

def File.basename_wo_ext(filename)
  File.basename(filename)[0..-(1+File.extname(filename).length)]
end