class Product < ActiveRecord::Base
  
  has_one :info
  
  attr_accessor :image_url#, (self.info ? self.info.image_url : '/')
  attr_accessor :name, :description, :unitprice, :image

  ['image_url', 'name', 'description', 'unitprice'].each do |arg|
    method_name = (arg + '_info').to_sym
    send :define_method, method_name do 
      if self.info
        return self.info.send(arg.to_sym)
      else
        return nil
      end
    end
  end
  
  validates_presence_of :amount
end
