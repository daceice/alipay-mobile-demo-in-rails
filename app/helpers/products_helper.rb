module ProductsHelper
  def product_icon_image(product)
    if product && product.info && product.info.image
      return image_tag product.info.image.url(:icon)
    else
      return nil
    end
  end
  
  def product_image(product)
    if product && product.info && product.info.image
      return image_tag product.info.image.url
    else
      return nil
    end
  end
  
end
