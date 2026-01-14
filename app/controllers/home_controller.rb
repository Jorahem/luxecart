class HomeController < ApplicationController
  def index
    # Pull some records if models exist; fall back to empty arrays if not
    @featured_products = defined?(Product) ? Product.limit(8).to_a : []
    @categories = defined?(Category) ? Category.limit(8).to_a : []
    # Example static testimonials (fallback)
    @testimonials = [
      { name: "Aisha M.", text: "Fast shipping, beautiful packaging — I'm in love with my purchase!", avatar: nil },
      { name: "Liam R.", text: "Top quality and excellent support. LuxeCart made it easy.", avatar: nil },
      { name: "Sofia P.", text: "Amazing selection and great deals — will order again.", avatar: nil }
    ]
  end
end