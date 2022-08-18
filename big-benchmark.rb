require 'terminal-table'
require 'benchmark'
require 'csv'
require 'fileutils'

SHEET_PATH = ENV['WORKBOOK'] || "300k_sales_records.xlsx"
BENCHMARK_TIME = ENV['TIME']&.to_i || 60.freeze # 1 minute

rubyxl = lambda do
  require 'rubyXL'
  RubyXL::Parser.parse(SHEET_PATH).worksheets[0].each do |row|
    row.cells.each { |row| row.value }
  end
end

simple_xlsx_reader = lambda do
  require 'simple_xlsx_reader'
  SimpleXlsxReader.open(SHEET_PATH).sheets[0].rows.each do |row|
    row.each { |cell| cell }
  end
end

creek = lambda do
  require 'creek'
  Creek::Book.new(SHEET_PATH).sheets[0].rows.each do |row|
    row.each { |_, cell| cell }
  end
end

roo = lambda do
  require 'roo'
  Roo::Excelx.new(SHEET_PATH).each_row_streaming do |row|
    row.each { |cell| cell.value }
  end
end

xsv = lambda do
  require 'xsv'
  sheet = Xsv::Workbook::open(SHEET_PATH).sheets[0].each_row do |row|
    row.each { |cell| cell }
  end
end

BENCHMARKS = {
  'rubyxl' => rubyxl,
  'simple_xlsx_reader' => simple_xlsx_reader,
  'creek' => creek,
  'roo' => roo,
  'xsv' => xsv
}.freeze

HEADERS = [
  'Gem',
  'Time',
  'RSS Increase'
]

def measure(name)
  if name == '_headers'
    puts
    puts "Testing against a #{(File.size(SHEET_PATH) / 1_024_000.0).round(3)}mb xlsx file"
    puts

    csv = File.open('benchmark.csv', 'a')
    (csv << HEADERS.join(',') + "\n")
    csv.close
    return
  end

  if name == '_report'
    puts
    table = CSV.read('benchmark.csv')
    headings = table.shift
    puts Terminal::Table.new(headings: headings, rows: table)
    FileUtils.rm('benchmark.csv')
    return
  end

  blk = BENCHMARKS[name]

  print "Measuring #{name} - RSS: "

  rss_before = `ps -o rss= -p #{Process.pid}`.chomp.to_i / 1_024.0
  bm = Benchmark.measure(&blk)
  rss_after = `ps -o rss= -p #{Process.pid}`.chomp.to_i / 1_024.0
  rss_usage = rss_after - rss_before

  puts "#{rss_usage.round(2)}mb, time: #{bm.total.round(2)}"

  csv = File.open('benchmark.csv', 'a')
  csv << [
    name,
    "#{bm.total.round(2)}s",
    "#{rss_usage.round(2)}mb"
  ].join(',') + "\n"
end

measure(ARGV[0])
