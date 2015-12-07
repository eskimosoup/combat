class Article < ActiveRecord::Base

  include Tp2Mixin
  include TimeStampable
  include ImageHolder
  include DocumentHolder
  include Taggable

  named_scope :displayable, :conditions => { :display => true}

  validates_presence_of :article_date, :message => "must be a valid date"

  def Article.empty?
    Article.displayable.empty?
  end

  def Article.find_latest_n(n)
    self.displayable.find(:all,
          :order => 'article_date desc',
          :limit => n)
  end

  def Article.find_recent(n="10")
    articles_by_n = Article.find_latest_n(n)
    articles_by_date = Article.displayable.find(:all, :order => "article_date desc",
                                            :conditions => "date_sub(curdate(), interval 30 day) <= article_date")
    if articles_by_n.length > articles_by_date.length
      articles_by_n
    else
      articles_by_date
    end
  end

  def Article.all_from_date(month, year)
    if not year
      year = Date.today.year
    end
    self.displayable.find(:all,
                :order => 'article_date desc',
                :conditions => ["month(article_date) = ? and year(article_date) = ?", month, year])
  end


end
