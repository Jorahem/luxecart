class AddSearchIndexesToProducts < ActiveRecord::Migration[7.1]
  def change
    # enable extensions if not already enabled
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    enable_extension "unaccent" unless extension_enabled?("unaccent")

    # create a tsvector column (optional; or you can compute on the fly)
    add_column :products, :search_vector, :tsvector

    # GIN index for fast search
    add_index :products, :search_vector, using: :gin, name: "index_products_on_search_vector"

    # Optionally, trigram index for similarity search on name
    add_index :products, :name, using: :gin, opclass: :gin_trgm_ops, name: "index_products_on_name_trgm"
  end
end