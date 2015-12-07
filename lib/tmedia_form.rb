class TmediaForm
  require RAILS_ROOT + '/lib/helpers'
  attr_accessor :form, :model

  def initialize(form, model)
    @form = form
    @model = model
  end

  def method_missing(id, *args)
    @form.send(id, *args)
  end

  def t_date_select(attribute)
    @form.calendar_date_select attribute, :time => false, :class => 'date_field'
  end

  def comprehensive_image_field(attribute)
    attribute = attribute.to_s.gsub("_id", "")
    fd_name = (attribute.to_s+"_file_data").to_sym
    ia_name = (attribute.to_s+"_image_alt").to_sym
    r_name = (attribute.to_s+"_remove").to_sym
    output = ""
#    output += "<fieldset>\n"
#    output += "<legend>#{attribute.to_s.split("_").map{|word| word.capitalize}.join(" ")}</legend>\n"
    output += "<br /><p><label for='#{fd_name}'>Image File</label>\n"
    output += @form.file_field(fd_name) + "</p>\n"
    output += "<p><label for='#{ia_name}'>Image Title</label>\n"
    output += @form.text_field(ia_name) + "</p>\n"
    if @model.send(("has_"+attribute.to_s+"?").to_sym)
      output += "<p>"+ help.thumbnail_tag(@model.send(attribute), :height => 100)+"</p>\n"
      output += "<p><label for='#{r_name}'>Remove Image</label>\n"
      output += @form.check_box(r_name, :class => "checkbox") + "</p>\n"
    end
    output
    #    output += "</fieldset>\n"
  end

  def comprehensive_document_field(attribute)
    attribute = attribute.to_s.gsub("_id", "")
    fd_name = (attribute.to_s+"_file_data").to_sym
    de_name = (attribute.to_s+"_description").to_sym
    r_name = (attribute.to_s+"_remove").to_sym
    output = ""
    output += "<fieldset>\n"
    output += "<legend>#{attribute.to_s.split("_").map{|word| word.capitalize}.join(" ")}</legend>\n"
    output += "<p><label for='#{fd_name}'>File</label>\n"
    output += @form.file_field(fd_name) + "</p>\n"
    output += "<p><label for='#{de_name}'>Description</label>\n"
    output += @form.text_field(de_name) + "</p>\n"
    if @model.send(("has_"+attribute.to_s+"?").to_sym)
      output += "<p><a href=\"#{@model.send(attribute).url}\">#{@model.send(attribute).filename}</a></p>\n"
      output += "<p><label for='#{r_name}'>Remove</label>\n"
      output += @form.check_box(r_name, :class => "checkbox") + "</p>\n"
    end
    output += "</fieldset>\n"
  end

  def summary_text_area(attribute)
    @form.text_area(attribute, :class => "summary")
  end

  def tinymce_text_area(attribute)
    @form.text_area(attribute, :class => "mceEditor")
  end

  def tag_field(attribute)
    output = @form.text_field(attribute)
    tag_links = []
    @model.class.all_tags_array.each do |tag|

      tag_links << help.link_to_function(tag, "tag_swap('#{tag}', '#{@model.class.to_s.downcase}_#{attribute}')", :id => "#{tag}_#{@model.class.to_s.downcase}_#{attribute}")
    end
    output << tag_links.join(" ")

  end

  def check_box(attribute)
    # I am WELL NOT HAPPY ABOUT THIS METHOD. This is a problem that should be fixed in css i am pretty certain
    @form.check_box(attribute, :class => "checkbox")
  end

  def default_collection_select(attribute)
    @form.collection_select(attribute, attribute.to_s.gsub("_id", "").camelcase.constantize.find(:all, :order => "name asc"), :id, :name)
  end

end
