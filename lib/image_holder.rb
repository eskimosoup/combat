module ImageHolder
#currently only has that one method. Might move some of the others in here if it seems to make sense.

  def self.included(base)
    picture_columns = base.column_names.select{|col| col =~ /^picture[0-9]*_id$/}
    picture_columns.each do |col|
      n = col.gsub(/[^0-9]*/, "").to_i
      attribute_name = col.gsub("_id", "")
      base.belongs_to(attribute_name.to_sym, :class_name => "Picture", :foreign_key => col)
      base.send(:define_method, "has_picture#{n}?") { self.send(attribute_name.to_sym) && self.send(attribute_name.to_sym).exists? }

      base.send(:attr_accessor, ((attribute_name + '_file_data').to_sym))
      base.send(:attr_accessor, ((attribute_name + '_image_alt').to_sym))
      base.send(:attr_accessor, ((attribute_name + '_remove').to_sym))
    end

    # add pictures
    base.send(:define_method, "pictures") { picture_columns.map{ |col| self.send(col.gsub("_id", "").to_sym)}.compact}
    #here we were doing base.send(:before_save blah
    base.before_save :update_pictures
  end

  def update_pictures
    picture_columns = self.attribute_names.select{|col| col =~ /^picture[0-9]*_id$/}
    picture_columns.each do |col|
      attribute_name = col.gsub("_id", "")
      if self.send((attribute_name+"_remove").to_sym) == "1"
        self.send((attribute_name+"=").to_sym, nil)
      end


      if self.send((attribute_name+ "_file_data").to_sym) && self.send((attribute_name+ "_file_data").to_sym).length != 0
          picture = Picture.create(:file_data => self.send((attribute_name+"_file_data").to_sym), :image_alt => self.send((attribute_name+"_image_alt").to_sym))
      end
      if picture
        self.send((attribute_name+"=").to_sym, picture)
      end
    end
  end

  def has_a_picture?
    not self.pictures.empty?
  end

end
