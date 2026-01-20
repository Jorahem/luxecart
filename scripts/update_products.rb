# scripts/update_products.rb
# Run with:
#   bin/rails runner scripts/update_products.rb
#
# 1) Prints every product: ID, current name, image URL
# 2) Lets you change names and image URLs in PRODUCT_UPDATES

puts "\n== CURRENT PRODUCTS (ID, Name, Image URL) ==\n\n"

Product.order(:id).each do |p|
  image =
    if p.respond_to?(:image_url) && p.image_url.present?
      p.image_url
    elsif p.respond_to?(:image) && p.image.is_a?(String)
      p.image
    else
      "(no image url column)"
    end

  puts "ID:    #{p.id}"
  puts "Name:  #{p.name}"
  puts "Image: #{image}"
  puts "-" * 60
end

########################################################################
# EDIT BELOW TO UPDATE PRODUCTS
#
# For each product you want to change, add an entry:
#
#   id => {
#     name:  "New Product Name",           # optional
#     image: "https://new-image-url.com"   # optional
#   }
#
# You can set only name, only image, or both.
########################################################################

PRODUCT_UPDATES = {
  # Examples (replace with your real IDs and URLs):
  1 => {
    name:  "Luxe Velvet Chair",
    image: "https://i5.walmartimages.com/seo/Baxton-Studio-Cosette-Glam-and-Luxe-Light-Pink-Velvet-Fabric-Upholstered-Brushed-Gold-Finished-Seashell-Shaped-Accent-Chair_738dabea-3730-47ea-909e-302eb8b0dc58.71eec7ddca6b8f7c68a83e84608d2738.jpeg"
  },
  2 => {
    name:  "Modern Floor Lamp",
    image: "https://di2ponv0v5otw.cloudfront.net/posts/2025/01/25/67951bf74f80f955002fecf9/m_67951c7547c130b2b0749efb.jpeg"
  },
  3 => {
    name:  "Handwoven Rug",
    image: "https://cdn.shopify.com/s/files/1/1159/3118/files/holiday24_ashlar-handwoven-rug-tawny_detail_silo-_1x1_jw.jpg?v=1736296960"
  }  ,
  4 => {
    name:  "Oak Coffee Table",
    image: "https://funky-chunky-furniture.co.uk/cdn/shop/products/salters-oak-coffee-table-33777-1-p.jpg?v=1643646322"
  }  ,
  5 => {
    name:  "Ceramic Vase Set",
    image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS9bINwLC6UkuTxtCmyTdWJ0v3OWdRSReZO6Q&s"
  }  ,
  6 => {
    name:  "Luxe Bed Linen",
    image: "https://sowlhome.com/cdn/shop/files/sowl_athens_bed_set_organic_100_cotton_percale_linen_beige_white_duvet_cover_240_220_pillow_cases_50_75_product.jpg?v=1715346346&width=1700"
  }  ,
  7 => {
    name:  "Minimalist Bookshelf",
    image: "https://theminimalistvegan.com/wp-content/uploads/2024/01/Best-Minimalist-Bookshelf-Design-Ideas.jpg"
  }  ,
  8 => {
    name:  "Designer Throw Pillow",
    image: "https://shoppersfortune.com/cdn/shop/files/ShoppersFortuneCottonFeelDesignerThrowPillowDecorativeCushionCovers-CuteOwls_FloraSetof5A.jpg?v=1689257687"
  }  ,
  9=> {
    name:  "Contemporary Wall Art",
    image: "https://ak1.ostkcdn.com/images/products/is/images/direct/ecb2a34deb10a54f12119f2adbf487d9d5444041/Designart-%22White-And-Blue-Feather-Spiral-II%22-Abstract-Geometric-Blue-Wall-Decor---Modern-Entryway-Framed-Wall-Art.jpg"
  }  ,
  10=> {
    name:  "Nordic Dining Chair",
    image: "https://image.made-in-china.com/365f3j00gpQoAnWECjcV/Nordic-Wooden-Dining-Chair-Cushion-Genuine-Fabric-Dinning-Chair.webp"
  }  ,
  11=> {
    name:  "Contemporary Wall Art",
    image: "https:/stract-Geometric-Blue-Wall-Decor---Modern-Entryway-Framed-Wall-Art.jpg"
  }  ,
  12=> {
    name:  "Sofa
    ",
    image: "https://sbfurniturenepal.com/web/image/230965-dad0558f/%5B19230543%5D%20Amiga%20Arm%20Chair%20-%20Birch%20Natural%20Wood%20-%20Light%20Gray.jpeg"
  }  ,
  13=> {
    name:  "Contemporary Wall Art",
    image: "https://ak1.ostkcdn.com/iEntryway-Framed-Wall-Art.jpg"
  }  ,
  14=> {
    name:  "Cushion Cover",
    image: "https://img.drz.lazcdn.com/static/np/p/b983893f8e9afec9f5e2a18ddb3727ab.jpg_720x720q80.jpg"
  }  ,
  15=> {
    name:  "Coffee Table",
    image: "https://cdn2.blanxer.com/uploads/6643159c6f73f03df02c1124/product_image-71yoiodtljl_ac_sl1024_-9087.webp"
  }  ,
  16=> {
    name:  "Wardrobe",
    image: "https://backend.furniturehub.com.np/uploads/product/compressed/images/Wardrobe_2.jpg"
  }  ,
  17=> {
    name:  "Wall Lamp",
    image: "https://m.media-amazon.com/images/I/61onjuf7GXS._AC_SL1000_.jpg"
  }  ,
  18=> {
    name:  "Wall Art",
    image: "https://www.indooroutdoors.co.uk/cdn/shop/files/tree-of-life-celtic-folk-minimalist-geometric-metal-wall-art-indoor-outdoors_1_e01532fa-744c-4988-afc7-efb4fb3a1efe.jpg?v=1699896173"
  },
  19=> {
    name:  "Floor Mat",
    image: "https://rukminim2.flixcart.com/image/480/640/xif0q/mat/y/e/y/free-foot-mat-with-anti-slip-strong-backing-door-mat-for-home-original-imagssvma2nybqgk.jpeg?q=90"
  }  ,
   
  20=> {
    name:  "Folding Table",
    image: "https://backend.furniturehub.com.np/uploads/product/images/folding_table.jpg"
  },
   21=> {
    name:  "Drawer Chest",
    image: "https://laurajamesfurniture.com/cdn/shop/files/essie-tall-7-drawer-chest-of-drawers-white-laura-james-1.jpg?v=1722851116&width=1946"
  }  ,
   22=> {
    name:  "LED Light",
    image: "https://img.drz.lazcdn.com/g/kf/Sf2203440abdf4914b88e1a3db576f7f2J.jpg_720x720q80.jpg"
  }  ,
   23=> {
    name:  "Candle Stand",
    image: "https://m.media-amazon.com/images/I/61Kza5pZ-UL._AC_UF350,350_QL80_.jpg"
},
   24=> {
    name:  "Poplin Fabric",
    image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTIh_CCqM0zo1N6B9-8vU1W8KGXdH43WdLjqQ&s"
  }  ,
   25=> {
    name:  "Center Table",
    image: "https://ik.imagekit.io/2xkwa8s1i/img/coffee-tables/java-coffee-table/1.jpg?tr=w-3840"
  }  ,
   26=> {
    name:  "Wardrobe",
    image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkjQb59hn-Vlko5JiXkro7AmOvyGBKk3C2tQ&s"
  }  ,
   27=> {
    name:  "Pendant Light",
    image: "https://www.illumination.co.uk/media/product/143886/1000x1000/calapa-pendant-light-h3640777-0.jpg"
  }  ,
   28=> {
    name:  "Sculpture",
    image: "https://www.sidonie-paris.com/cdn/shop/files/Luwana_sculpture_en_gres.jpg?v=1731938680&width=3555"
  }  ,
   29=> {
    name:  "Table Cloth",
    image: "https://m.media-amazon.com/images/I/71KfAHuRbyL._AC_SL1000__.jpg"
}  ,
   30=> {
    name:  "Console Table",
    image: "https://i5.walmartimages.com/asr/87557c0d-03a1-4651-b48d-28c5e77f934e.a8608b594e981dca190b8c47f2beebeb.jpeg"
  }  ,
   31=> {
    name:  "Dining Set",
    image: "https://i5.walmartimages.com/seo/SEGMART-Dining-Table-4-High-back-Upholstered-Chairs-Modern-Dinette-Set-Dining-Table-Chairs-Set-4-Persons-Small-Home-Kitchen-Dining-Table-Set-Ideal-Ap_ca195baa-2f73-4cc2-98ec-cd3bd87fc569.2d4cd4af10d56aff77c93921572c2911.jpeg"
  }   ,
   32=> {
    name:  "Night Lamp",
    image: "https://i.etsystatic.com/15042561/r/il/0775c1/1258102641/il_570xN.1258102641_a2qm.jpg"
  }   ,
   33=> {
    name:  "Royal Dining Table",
    image: "https://m.media-amazon.com/images/I/81KQ5GQfrXL._AC_UF894,1000_QL80_.jpg"
  }   ,
   34=> {
    name:  "Bench",
    image: "https://m.media-amazon.com/images/I/91LNPvP-37L._AC_SL1000__.jpg"
  }   ,
   35=> {
    name:  "Tube Light",
    image: "https://cdn.accentuate.io/605705339184/-1695035269432/light-1-v1695038331953.png?800x800
    "
  }   ,
   35=> {
    name:  "Console Table",
    image: "https://i5.walmartimages.com/asr/87557c0d-03a1-4651-b48d-28c5e77f934e.a8608b594e981dca190b8c47f2beebeb.jpeg"
  }

}

########################################################################

if PRODUCT_UPDATES.any?
  puts "\n== APPLYING UPDATES ==\n\n"
  PRODUCT_UPDATES.each do |id, attrs|
    product = Product.find_by(id: id)
    unless product
      puts "ID #{id}: product not found (skipped)"
      next
    end

    old_name = product.name
    old_image =
      if product.respond_to?(:image_url) && product.image_url.present?
        product.image_url
      elsif product.respond_to?(:image) && product.image.is_a?(String)
        product.image
      else
        nil
      end

    if attrs[:name].present?
      product.name = attrs[:name]
    end

    if attrs[:image].present?
      if product.respond_to?(:image_url=)
        product.image_url = attrs[:image]
      elsif product.respond_to?(:image=) && Product.column_names.include?('image')
        product.image = attrs[:image]
      end
    end

    product.save!

    puts "ID #{id}:"
    if attrs[:name].present?
      puts "  Name:  '#{old_name}' -> '#{product.name}'"
    end
    if attrs[:image].present?
      puts "  Image: '#{old_image}' -> '#{attrs[:image]}'"
    end
    puts "-" * 60
  end

  puts "\nDone. Refresh your website to see new names and images."
else
  puts "\nPRODUCT_UPDATES is empty. No products were changed."
  puts "To update, edit scripts/update_products.rb and fill PRODUCT_UPDATES."
end