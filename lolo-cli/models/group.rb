class Group

  attr_accessor :id, :name, :on

  def self.all
    groups = []
    response = RestClient.get $uri + "/#{$key}/groups"
    response = JSON.parse(response)
    response.each do |nr, group|
      g = Group.new
      g.id = nr
      g.name = group["name"]
      groups << g
    end
    return groups
  end

end
