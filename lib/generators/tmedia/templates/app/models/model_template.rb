class <%= class_name %> < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder

  def <%= class_name %>.empty?
    <%= class_name %>.find(:all).empty?
  end

end
