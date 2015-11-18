class SubcommandLightGroup

  # This function is called from Clamp. Clamp tries to find
  # a subcommand by comparing the subcommand to the string passed
  # on the console. This hijacks the comparison and looks for
  # Lights or Groups that match the specified name.
  def ==(other_object)
    if $light = Group.find_by_name(other_object)
      return true
    end
    if $light = Light.find_by_name(other_object)
      return true
    end
    if $light = Light.find_by_id(other_object)
      return true
    end
    return false
  end

  # Used to beautify the Clamp usage.
  def to_s
    return "<light|group> <on|off>"
  end
end

class SubcommandScene

  # This function is called from Clamp. Clamp tries to find
  # a subcommand by comparing the subcommand to the string passed
  # on the console. This hijacks the comparison and looks for
  # Scenes that match the specified name.
  def ==(other_object)
    if $light = Scene.find_by_name(other_object)
      return true
    end
    return false
  end

  # Used to beautify the Clamp usage.
  def to_s
    return "<scene>"
  end
end
