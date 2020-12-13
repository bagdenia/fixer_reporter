# example usage
# ruby reporter.rb --base=EUR --other=RUB --date=2020-12-10
# deeafult date - today, currencies BASE and OTHER values
require 'net/http'
require 'aws-sdk-s3'
require 'timerizer'
require 'dotenv/load'
require 'yaml'
require 'pry-byebug'
require 'bigdecimal'

BASE = 'EUR'
OTHER = 'USD'
FORMATS = %w[json csv html xml].freeze
BASE_FORMAT = 'csv'

FORMATS.each do |format|
  require_relative "reports/#{format}"
end

def config
  @config ||= YAML.load(File.read('config.yml'))
end

def get_rate(date)
  uri = URI(url(date.to_date.to_s))
  params = { base: base, other: other }
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  pp uri
  raise response.body unless response.is_a?(Net::HTTPSuccess)

  rate = JSON.parse(response.body)['rate']
  BigDecimal(rate).round(4)
end

def rates
  @rates_data ||= begin
    {
      today: get_rate(date),
      yesterday: get_rate(1.day.before(date)),
      week_ago: get_rate(1.week.before(date)),
      month_ago: get_rate(1.month.before(date)),
      year_ago: get_rate(1.year.before(date))
    }
  end
end

def deltas
  @deltas ||= begin
    {
      rate: rates[:today].to_s('F'),
      day_change: rates[:today] - rates[:yesterday],
      week_change: rates[:today] - rates[:week_ago],
      month_change: rates[:today] - rates[:month_ago],
      year_change: rates[:today] - rates[:year_ago],
    }.transform_values(&:to_f)
  end
end

def url(date)
  "#{config['proxy_url']}/api/v1/rates/#{date}"
end

def params
  @params ||= Hash[ARGV.join(' ').scan(/--?([^=\s]+)(?:=(\S+))?/) ]
end

def base
  @base ||= params['base'] || BASE
end

def other
  @other ||= params['other'] || OTHER
end

def date
  @date ||= (params_date || Date.today)
end

def format
  @format ||= params['format'] || BASE_FORMAT
end

def params_date
  return unless params['date']

  Date.parse(params['date'])
end

def create_report(format)
  raise 'Unpermitted report format' unless FORMATS.include?(format)
  file_path = "storage/#{date}_#{base}_#{other}.#{format}"
  File.write(file_path, send("generate_#{format}", deltas))
  pp "#{file_path}"
  file_path
end

pp params
Dotenv.load

file_path = create_report(format)

if config['environment'] == 'production'
  return unless file_path
  s3 = Aws::S3::Resource.new(region: 'us-east-2')
  bucket = ENV['BUCKET']

  obj = s3.bucket(bucket).object(File.basename(file_path))
  obj.upload_file(file_path)
  pp "Uploaded to AWS: #{file_path}"
end
