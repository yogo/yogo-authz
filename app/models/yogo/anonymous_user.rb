# Mimicks a normal user?
class Yogo::AnonymousUser
  
  def name
    Yogo::Settings[:anonymous_user_name]
  end
  
  def has_group?(value)
    return value.eql?(Yogo::Settings[:anonymous_user_group])
  end
end