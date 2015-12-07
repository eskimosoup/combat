# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def page_title
    @page_title || ""
  end

  def scale_image_tag(picture, options = {})
    if picture
      image_tag(Picture.image_url(picture.resize(options[:width].to_i, options[:height].to_i)), options.merge({:alt => picture.image_alt, :title => picture.image_alt}))
    else
      image_tag("clear.gif", options)
    end
  end

  def thumbnail_tag(picture, options = {})
    link_to(scale_image_tag(picture, options.merge({:border => 0})), "/settings/view_image/#{picture.id}", :popup => ["_blank", "width=#{picture.width+15},height=#{picture.height + 10}"])
  end

  def admin_table(locals_in)
    defaults = {:edit_action => 'edit', :list_action => 'list', :delete_action => 'delete', :order_action => 'order', :view_action => false, :no_order => false}
    columns = locals_in[:columns].map do |column|
      if column.kind_of?(String) or column.kind_of?(Symbol)
        column = column.to_s
        if column.split("_").last == "id"
          cname = column.gsub("_id", "")
          # here, possibly change the middle entry to say cname, and redefine the printing method of the object?
          [cname.split("_").map{|w| w.capitalize}.join(" "), lambda{|o| o.send(cname) ? o.send(cname).name : ""}, column]
        else
          [column.split("_").map{|w| w.capitalize}.join(" "), column, column]
        end
      else
        column
      end
    end
    locals = defaults.merge(locals_in).merge(:columns => columns)
    render :partial => "shared/admin_table", :locals => locals
  end

  def last_updated_field(obj)
    "<acronym title=\"updated by: #{obj.updated_by}\">#{(obj.last_updated.strftime("%d %B"))}</acronym>"
  end

  def link_with_params(text, options={}, html_options={})
    link_to(text, params.merge(options), html_options)
  end

  def copyright_message(start_year)
    end_year = ""
    if start_year != Date.today.year
      end_year = " - " + Date.today.year.to_s
    end
    "&copy; T Media Ltd #{start_year}" + end_year
  end

  def short_text_date(date)
    if date
      date.day.to_s + " " + ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][date.month - 1] + " " + date.year.to_s
    else
      ""
    end
  end

  def month_name(month)
    ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][month]
  end


end
