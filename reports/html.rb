require 'builder'

def generate_html(hash)
  html = Builder::XmlMarkup.new(indent: 2)
  html.body do
    hash.each do |k, v|
      html.h2("#{k}: #{v}")
    end
  end
end
