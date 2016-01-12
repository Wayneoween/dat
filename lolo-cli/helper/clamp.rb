class SubcommandGroup
  # This function is called from Clamp. Clamp tries to find
  # a subcommand by comparing the subcommand to the string passed
  # on the console. This hijacks the comparison and looks for
  # Groups that match the specified name.
  def ==(other_object)
    return false if $commands.any?{|cmd| cmd.include?(other_object) }

    if $light = Group.find_by_name(other_object)
      return true
    end
    if $light = Group.find_by_id(other_object)
      return true
    end
    return false
  end

  # Used to beautify the Clamp usage.
  def to_s
    return "<group> <on|off>"
  end
end

class SubcommandLight
  # This function is called from Clamp. Clamp tries to find
  # a subcommand by comparing the subcommand to the string passed
  # on the console. This hijacks the comparison and looks for
  # Lights that match the specified name.
  def ==(other_object)
    return false if $commands.any?{|cmd| cmd.include?(other_object) }

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
    return "<light> <on|off>"
  end
end

class SubcommandScene
  # This function is called from Clamp. Clamp tries to find
  # a subcommand by comparing the subcommand to the string passed
  # on the console. This hijacks the comparison and looks for
  # Scenes that match the specified name.

  def ==(other_object)
    return false if $commands.any?{|cmd| cmd.include?(other_object) }

    if $light = Scene.find_by_name(other_object)
      return true
    end
    if $light = Scene.find_by_id(other_object)
      return true
    end
    return false
  end

  # Used to beautify the Clamp usage.
  def to_s
    return "<scene>"
  end
end
