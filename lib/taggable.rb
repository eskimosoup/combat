module Taggable
  module ClassMethods

    def all_tags_array
#      tag_ids = Tagging.find(:all, :conditions => ["taggable_type = ?", self.to_s]).collect{ |tagging| tagging.tag_id}
      all_tag_objects_array.collect(&:name)
    end

    def all_tag_objects_array
      tag_ids = Tagging.find_by_sql(["SELECT DISTINCT tag_id FROM taggings WHERE taggable_type = ?", self.to_s]).collect{ |tagging| tagging.tag_id}
      ( Tag.find(tag_ids))
    end

    def all_tags
      all_tags_array.join ", "
    end

    def model_ids(tag_string)
      tag = Tag.find_by_name(tag_string.strip)
      if tag
        model_id_list = Tagging.find_by_sql(["SELECT DISTINCT taggable_id from taggings where taggable_type = '#{self.to_s}' and tag_id = ?", tag.id]).collect(&:taggable_id)
      end
    end

    def find_tagged(tag_string, options={ })
      model_id_list = model_ids(tag_string)
      if !model_id_list.empty?
        self.find(model_id_list, options)
      else
        []
      end
    end

    def find_displayable_tagged(tag_string, options={ })
      find_tagged(tag_string, options={}).select{|model_instance| model_instance.display?}
    end


  end

  def self.included(base)
    base.after_save :write_tags
    base.extend ClassMethods
    base.has_many :taggings, :as => :taggable, :dependent => :destroy
  end

  def tag_objects_array
    tag_ids = []
    self.taggings.map{|tagging| tag_ids << tagging.tag_id}
    Tag.find(tag_ids)
  end

  def tag_array
    tag_objects_array.collect{ |tag| tag.name}
  end

  def tags
    unless new_record?
      taggings.reload
    end
    tag_array.join ", "
  end

  def tags=(input)
    @temp_tags=input
    unless new_record?
      @temp_tags.strip!
      if @temp_tags != ""
        write_tags
      end
    end
  end

  def write_tags
    if !@temp_tags.nil?
      self.taggings.map(&:destroy)
      tag_arr = @temp_tags.split ","
      tag_arr.map do |tag_string|
        unless (tag_string = tag_string.strip) == ""
          self.taggings.create(
                               :tag_id => Tag.find_or_create_by_name(tag_string.strip).id
                               )
        end
      end
    end
    true
  end

  def tagged?(tag)
    tag_array.include?(tag)
  end

end
