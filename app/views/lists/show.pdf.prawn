prawn_document({:optimize_objects=>true,:compress=>true}) do |pdf|
  pdf.text "#{@list.name}", :style => :bold, :size => 16
  pdf.move_down 10
  res = Array.new
  @companies.each do |c|
    res.push(c) if image_exists?("#{c.ticker}_mma.png")
  end
  res.each_slice(3).to_a.each do |s|
    data = Array.new
    s.each do |c|
      subtable = pdf.make_table([ [{:image => "#{Rails.root}/app/assets/images/#{c.ticker}_mma.png", :scale => 0.60}, {:image => "#{Rails.root}/app/assets/images/#{c.ticker}_range.png", :scale => 0.60}] ], :cell_style => {:borders => []})
      name = c.name
      ticker = Prawn::Table::Cell::Text.new(pdf, [0,0], :content => "<b>#{c.ticker}</b>", :inline_format => true)
      name = Prawn::Table::Cell::Text.new(pdf, [0,0], :content => "#{name}", :inline_format => true)
      industry = Prawn::Table::Cell::Text.new(pdf, [0,0], :content => c.industry, :inline_format => true)
      data.push([ticker, name, industry])
      data.push([{:content => subtable, :colspan => 3}])
    end
    if data.size > 0
    pdf.table data, :cell_style => {:size => 11} do
      row(0..-1).borders = []
      cells.style do |c|
        if (c.row % 2).zero?
          c.text_color = '404040'
          c.background_color = 'cccccc'
          c.borders = [:top]
          c.border_color = '555555'
        else
          c.background_color = 'f0f0f0'
        end
        row(-1).style :borders => [:bottom], :border_color => '555555'
      end
      column(0).style :align => :left, :width => 60
      column(1).style :align => :left, :width => 300
      column(2).style :align => :right, :width => 180
    end
    end
    pdf.start_new_page
  end
  pdf.number_pages "Page <page>/<total>", { :start_count_at => 0, :page_filter => :all, :at => [pdf.bounds.right - 50, 0], :align => :right, :size => 10, :color => 'a0a0a0' }
end