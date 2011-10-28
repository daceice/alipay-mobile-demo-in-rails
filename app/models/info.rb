class Info < ActiveRecord::Base
  
  
  has_attached_file :image,
     :styles => {
       :icon => "40x50#",
       :normal => "200x400#",
       },
     :url => "/uploadfiles/:class/:attachment/:id/:basename/:style.:extension",
     :path => ":rails_root/public/uploadfiles/:class/:attachment/:id/:basename/:style.:extension"

   validates_attachment_content_type :image, :content_type =>   ['image/jpeg', 'image/png','image/gif']
  
  
end
