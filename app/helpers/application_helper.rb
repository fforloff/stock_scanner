module ApplicationHelper
   def image_exists?(image)
        img = "#{Rails.root}/app/assets/images/#{image}"
        File.exists?(img)
   end
end
