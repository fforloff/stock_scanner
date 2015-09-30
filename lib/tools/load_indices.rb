def load_indices
  ordinary_indices = [
    {ticker: 'AORD', name: "All Ordinaries"},
    {ticker: 'AXSO', name: "Small Ordinaries"}
    ]
  industry_sectors_indices = [
    {ticker: 'AXEJ', name: "Energy"},
    {ticker: 'AXMJ', name: "Materials"},
    {ticker: 'AXNJ', name: "Industrials"},
    {ticker: 'AXHJ', name: "Healh Care"},
    {ticker: 'AXDJ', name: "Consumer Discretionary"},
    {ticker: 'AXSJ', name: "Consumer Staples"},
    {ticker: 'AXFJ', name: "Financials"},
    {ticker: 'AXIJ', name: "Information Technology"},
    {ticker: 'AXTJ', name: "Telecommunications"},
    {ticker: 'AXTJ', name: "Telecommunications"},
    {ticker: 'AXUJ', name: "Utilities"}
    ]

   ordinary_indices.concat(industry_sectors_indices).each do |i|
     Index.create({
       :name => i[:name],
       :ticker => i[:ticker],
     }) unless Index.where(ticker: "#{i[:ticker]}").exists?
   end
   Index.create_indexes()
  return true
end
