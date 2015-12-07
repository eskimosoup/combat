class ContentPage < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder

  def ContentPage.empty?
    ContentPage.find(:all).empty?
  end

  def ContentPage.find_by_url(controller, action)
    ContentPage.find(:first, :conditions => ["controller = ? and action = ?", controller, action])
  end

  def sorter
    temper = { 953125641 => 1, 996332877 => 2, 442820205 => 3, 1054583384 => 4, 1003532957 => 5}
    return temper[self.id]
  end

end
