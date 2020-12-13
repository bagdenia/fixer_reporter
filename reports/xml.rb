require 'builder'

def generate_xml(hash)
  builder = Builder::XmlMarkup.new(:indent=>2)
  builder.data do |b|
    hash.each do |k,v|
      b.__send__(k,v)
    end
  end

  builder.target!
end
