require 'ostruct'

class AdminNavigation

  attr_accessor :data

  def open?(tl, controller)
    all_controllers = []
    tl.next_level.each do |n|
      all_controllers << n.controller
      n.next_level do |m|
        all_controllers << m.controller
      end
    end
    all_controllers.index(controller)
  end

  def initialize
    yml = YAML::load(File.open("#{RAILS_ROOT}/config/admin_navigation.yml"))
    @data = yml.map {|tl| make_level_one(tl)}
  end

  def make_level_one(hash)
    if hash["list"]
      list = hash["list"].map{|n| make_level_two(n)}
    else
      list = []
    end
    OpenStruct.new(:title => hash["link"]["title"], :hclass => hash["link"]["class"], :next_level => list)
  end

  def make_level_two(hash)
    if hash["list"]
      list = hash["list"].map{|n| make_level_three(n)}
    else
      list = []
    end
    OpenStruct.new(:title => hash["link"]["title"], :controller => hash["link"]["controller"], :action => hash["link"]["action"], :next_level => list)
  end

  def make_level_three(hash)
    OpenStruct.new(:title => hash["title"], :controller => hash["controller"], :action => hash["action"])
  end

  def top_level
    @data
  end

end
