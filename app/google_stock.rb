class GoogleStock
    def self.is_valid_stock(query)
		Dispatch::Queue.concurrent.sync do
		  begin
		    	data = NSData.alloc.initWithContentsOfURL(NSURL.URLWithString(GoogleStock.url(query)))
		    	return (data.to_s.split('company data=')[1].split('/>')[0] != "\"\"")
		  rescue RuntimeError => e
		    presentError e.message
		  end
		end 

		## Bubble Wraper
		# BW::HTTP.get(GoogleStock.url(query)) do |response|
		# 	p response.to_s
		#   response.body.to_s.split('company data=')[1].split('/>')[0] != "\"\""
		# end  
		
		# feed = BW::RSSParser.new(GoogleStock.url(query))
		# feed.delegate = self
		# feed.parse do |item|
		# 	return item.company.data != ""
		# end

		## Wakizashi Wraper
		# Dispatch::Queue.concurrent.sync do
		#   begin
		#     	data = NSData.alloc.initWithContentsOfURL(NSURL.URLWithString(GoogleStock.url(query)))
		#     	parser = Wakizashi::XML(data)
		#     	return parser.company.data != ""
		#   rescue RuntimeError => e
		#     presentError e.message
		#   end
		# end 

		## Hpple Wraper
		# Dispatch::Queue.concurrent.sync do
		#   begin
		#     	xml = NSData.alloc.initWithContentsOfURL(NSURL.URLWithString(GoogleStock.url(query)))
		#     	parser = Hpple.XML(xml)
		#     	return parser.company.data != ""
		#   rescue RuntimeError => e
		#     presentError e.message
		#   end
		# end 
    end
    def self.url(query)
    	"http://www.google.com/ig/api?stock=#{query}"
	end
end