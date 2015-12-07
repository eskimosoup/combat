class Picture < ActiveRecord::Base

  DIRECTORY = RAILS_ROOT + '/public/images/gallery'

  before_save :check_file_data
  after_save :process
  after_destroy :cleanup

  include TimeStampable
  before_save :time_stamp

  belongs_to :picture
  has_many :pictures


  require "RMagick"
  include Magick

  def file_data=(file_data)
    unless file_data.size == 0
      @file_data = file_data
      write_attribute 'filename', file_data.original_filename
    end
  end

  def check_file_data
    @file_data
  end

  def path
    File.join(DIRECTORY, "#{self.filename}")
  end

  def url
    "/images/gallery/#{self.filename}"
  end

  def resize(width=nil, height=nil, stretchp=nil)
    if width == 0
      width = nil
    end
    if height == 0
      height = nil
    end
    if self.exists?
      new_filename = self.new_filename(width, height)
      unless File.exists?(Picture.file_path(new_filename))

        image = ImageList.new(self.file_path)
        iw = image.columns
        ih = image.rows

        if width and height

          if height.to_f/width.to_f >= ih.to_f/iw.to_f
            image.change_geometry!("x" + height.to_s) {|w, h, img| img.resize!(w, h)}
          else
            image.change_geometry!(width.to_s) {|w, h, img| img.resize!(w, h)}
          end
          image.crop!(CenterGravity, width, height)

        elsif width and image.columns > width
          image.change_geometry!(width.to_s) do |w, h, img|
            img.resize!(w, h)
          end
        elsif height and image.rows > height
          image.change_geometry!("x" + height.to_s) do |w, h, img|
            img.resize!(w, h)
          end
        end
        image.write("#{RAILS_ROOT}/public/images/gallery/#{new_filename}")
      end
      new_filename
    end
  end

  def new_filename(width=nil, crop_height=nil)
    if not (width or height)
      self.filename
    else
      split = self.filename.split(".")
      new_filename = split[0...split.length-1].join
      new_filename += "w" + width.to_s
      if crop_height
        new_filename += "h" + crop_height.to_s
      end
      new_filename +=  "." + split.last
      new_filename
    end
  end

  def Picture.increment_count(filename)
    base = get_basename(filename)
    split = base.split("_")
    if split.last.to_i == 0
      ret = split.join("_") + "_1" + get_extension(filename)
      if File.exists?(File.join(DIRECTORY, "#{ret}"))
        Picture.increment_count(ret)
      else
        ret
      end
    else
      split[split.length-1] = (split[split.length-1].to_i + 1).to_s
      ret = split.join("_")  + get_extension(filename)
      puts ret
      if File.exists?(File.join(DIRECTORY, "#{ret}"))
        Picture.increment_count(ret)
      else
        ret
      end
    end
  end

  def Picture.get_extension(filename)
    filename[filename.rindex(".")..filename.length]
  end

  def Picture.get_basename(filename)
    filename[0...filename.rindex(".")]
  end

  def exists?
    File.exists?(self.file_path)
  end

  def Picture.file_path(filename="")
    "#{RAILS_ROOT}/public/images/gallery/#{filename}"
  end

  def file_path
    Picture.file_path(self.filename)
  end

  def Picture.image_url(filename="")
    "/images/gallery/#{filename}"
  end

  def image_url
    Picture.image_url(self.filename)
  end

  def width_and_height
    if self.exists?
      img = Magick::Image::read(self.file_path).first
      [img.columns, img.rows]
    else
      [0, 0]
    end
  end

  def width
    self.width_and_height[0]
  end

  def height
    self.width_and_height[1]
  end

  def Picture.in_use(file)
    in_use = false
    Picture.find(:all).each do |picture|
      unless in_use
        if file.index(Picture.get_basename(picture.filename))
          in_use = true
        end
      end
    end
    in_use
  end

  def Picture.collect_garbage
    Dir.foreach("#{RAILS_ROOT}/public/images/gallery") do |file|
      unless [".", ".."].index(file)
        unless Picture.in_use(file)
          File.delete("#{RAILS_ROOT}/public/images/gallery/#{file}")
        end
      end
    end

  end

  def after_destroy
    Picture.collect_garbage
  end

  private

  def process
    if @file_data
      save_file
      @file_data = nil
    end
  end

  def save_file
    if @file_data.content_type =~ /^image/
      filename = @file_data.original_filename
      if File.exists?(self.path)
        self.filename = Picture.increment_count(filename)
      end
      File.open(self.path, "wb") do |f|
        f.write(@file_data.read)
      end
      self.filename = filename
      # this code is specifically for resizing the image if it is too large
      image = ImageList.new(self.path)
      image.density = "72x72"
      if (image.columns > 750) or (image.rows > 550)
        image.change_geometry!("750x550") {|cols, rows, img|
          img.resize!(cols, rows)
        }
      end
      image.write(self.path)
    end

  end

  def cleanup
    Dir[File.join(DIRECTORY, "#{self.filename}")].each do |filename|
      File.unlink(filename) rescue nil
    end
  end

end
