# Mimicks a normal user?
class Yogo::AnonymousUser
  
  def name
    Yogo::Settings[:anonymous_user_name]
  end
  
  def has_group?(value)
    return value.eql?(Yogo::Settings[:anonymous_user_group])
  end
  
  def method_missing(method, *args)
    if eval(Yogo::Settings[:user_class]).new.respond_to?(method)
      raise Yogo::UserMethodOnAnonymousUser.new("undefined method '#{method}' for #{self}. Did you mean to call it on a #{Yogo::Settings[:user_class]} class instead?")
    else
      raise NoMethodError.new("undefined method '#{method}' for #{self}")
    end
    
  end
end