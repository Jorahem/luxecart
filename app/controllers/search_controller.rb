class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    @products =
      if @query.blank?
        Product.none
      else
        # try full-text first; if nothing, fall back to fuzzy name search
        results = Product.full_text_search(@query).limit(50)
        results = Product.name_fuzzy_search(@query).limit(50) if results.empty?
        results
      end
  end
end