
def __new_class_object(size)
  ob = malloc(size)
  %s(assign (index ob 0) Class)
  ob
end

class Class
  def new
    # @instance_size is generated by the compiler. YES, it is meant to be
    # an instance var, not a class var
    ob = malloc(@instance_size*4) 
    %s(assign (index ob 0) self)
    ob
  end
end

