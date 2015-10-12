def load_indices
  indices = [
    {ticker: '^AORD', name: "All Ordinaries", category: "ordinary"},
    {ticker: '^AXSO', name: "Small Ordinaries", category: "ordinary"},
    {ticker: '^AXEJ', name: "Energy", category: "GICS"},
    {ticker: '^AXMJ', name: "Materials", category: "GICS"},
    {ticker: '^AXNJ', name: "Industrials", category: "GICS"},
    {ticker: '^AXHJ', name: "Healh Care", category: "GICS"},
    {ticker: '^AXDJ', name: "Consumer Discretionary", category: "GICS"},
    {ticker: '^AXSJ', name: "Consumer Staples", category: "GICS"},
    {ticker: '^AXFJ', name: "Financials", category: "GICS"},
    {ticker: '^AXIJ', name: "Information Technology", category: "GICS"},
    {ticker: '^AXTJ', name: "Telecommunications", category: "GICS"},
    {ticker: '^AXPJ', name: "A-REIT", category: "GICS"},
    {ticker: '^AXUJ', name: "Utilities", category: "GICS"}
    ]

   indices.each do |i|
     Index.create({
       :name => i[:name],
       :ticker => i[:ticker],
       :category => i[:category]
     }) unless Index.where(ticker: "#{i[:ticker]}").exists?
   end
   Index.create_indexes()
  return true
end
