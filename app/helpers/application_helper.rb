module ApplicationHelper
  def image_exists?(image)
    img = "#{Rails.root}/app/assets/images/#{image}"
    File.exists?(img)
  end
  def page_title(name)
    pencil = "<i class='fa fa-pencil'></i>"
    trash = "<i class='fa fa-trash-o'></i>"
    html = ''
    html << "<h4 class='text-primary'>"
    html << "#{name} | "
    html << link_to(pencil.html_safe,  {:action => "edit"})
    html << " | "
    html << link_to(trash.html_safe, name, { :method => "delete", :confirm => 'Are you sure?'})
    html << "</h4>"
    html.html_safe
  end
end
