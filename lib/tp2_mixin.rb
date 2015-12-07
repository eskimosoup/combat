module Tp2Mixin

  module ClassMethods
    def paginate_and_order(params, page_size=10)
      Pager.pages(self, params[:page], page_size, {:query => query(params), :order => order(params), :includes => includes})
    end

    def includes
      ret = []
      self.columns.select{|column| column.name =~ /_id/ }.each do |column|
        ret << column.name.chomp("_id").to_sym
      end
      ret
    end

    def order(params)

      if params[:order_field]
        dir = params[:order_direction] || "asc"
        if params[:order_field] =~ /_id/
          params[:order_field] = params[:order_field].chomp "_id"
          params[:order_field] = self.reflect_on_all_associations(:belongs_to).select{ |ass| ass.name == params[:order_field].to_sym}.first.name.to_s.pluralize + '.name'
        end
        return "#{params[:order_field]} #{dir}"
      end
    end

    def query(params)
      query = "true"
      if params[:search]
        text_fields = self.columns.select{ |column| column.type == :string || column.type == :text}
        search_array = []
        text_fields.each do |field|
          search_array << "#{field.name} LIKE :search"
        end
        query = [query, search_array.join(" OR ")].join " AND "
      end
      return [query, { :search => "%#{params[:search]}%"}]
    end

    def random_n(n=1)
      #mysql only you guys
      self.find(:all, :order => "RAND()", :limit => n)
    end
  end

  def self.included(base)
    base.extend ClassMethods
    base.named_scope(:displayable, :conditions => { :display => true})
  end

  def initialize(*params)
    super(*params)
    if self.respond_to?("display=".to_sym)
      self.display = true
    end
  end

end
