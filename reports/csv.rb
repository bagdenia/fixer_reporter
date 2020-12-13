require 'csv'

def generate_csv(hash)
  CSV.generate do |csv|
    csv << hash.keys
    csv << hash.values
  end
end
