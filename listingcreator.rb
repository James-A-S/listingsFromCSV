#!/usr/bin/env ruby

## A simple script that parses a csv file and converts it to an array of hashes and creates an item listing for each row marked as unlisted in the csv.
## Also creates a to do list of items that still need to be photographed

require 'csv'
require 'English'
require 'fileutils'

def read_line_num(filename, number)
    found_line = nil
    File.foreach(filename) do |line|
        if $INPUT_LINE_NUMBER == number
            found_line = line.chomp
            break
        end
    end
    found_line
end

CSV::Converters[:blank_to_nil] = lambda do |field|
    field && field.empty? ? nil : field
end

path = ARGV[0][7..-1]
sheetname = ARGV[1]

## read csv and convert to array of hashes, blank fields to nil
rows_as_hash = CSV.read("#{path}ebay_stock_#{sheetname}.csv", :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])

subdir = "#{path}#{sheetname}/"
Dir.mkdir(subdir) unless File.exists?(subdir)
Dir.mkdir("#{subdir}/completed") unless File.exists?("#{subdir}/completed")
html_source = "/home/james/github/ruby_utils/listingcreator/master_#{sheetname}.html"
head = File.read("/home/james/github/ruby_utils/listingcreator/head.html")
htmltext = File.read(html_source)
csstext = File.read("/home/james/github/ruby_utils/listingcreator/elist_style1.css").to_s

chklists =  [
            {prefix: "photos_req_", heading: "Photos required:"},
            {prefix: "listing_checklist_", heading: "Items ready to list:"}
            ]

## Delete and add headings to previous to do / checklists
chklists.each do |chk|
fname = "#{subdir}#{chk[:prefix]}#{sheetname}.txt"
    if File.exists?(fname) then File.delete(fname) end
    File.open(fname, 'a+') { |f| f.puts("#{chk[:heading]} #{sheetname}\n\n") }
end

rows_as_hash.each do |row|

    listfile = "listingtext_#{sheetname}_#{row[:item_num]}.txt"
    htmlfile = "listingtext_#{sheetname}_#{row[:item_num]}.html"
    fpath = "#{subdir}#{listfile}"
    hpath = "#{subdir}#{htmlfile}"
    lineone = read_line_num(html_source, 1)[5..-5]
    info = "Item: #{row[:item_num]}     #{lineone % row}"

    if row[:listed] == nil && row[:photo] == "y" ## Check listing status & create pastable text files and html previews

        ## create listing text for unlisted items
        File.open(fpath, 'w+') do |f|  # TEXT OUTPUT
            f.puts("<style>\n#{csstext}</style\n\n")
            f.puts(htmltext % row)
        end

        File.open(hpath, 'w+') do |f|  #  HTML OUTPUT
            f.puts(head % row)
            f.puts("\n<body>")
            f.puts(htmltext % row)
            f.puts("\n</body>")
        end

        ## Append to checklist
        File.open("#{subdir}listing_checklist_#{sheetname}.txt", 'a+') { |f| f.puts(info) }

    ## cleanup completed listings
    elsif (row[:listed] == "y" || row[:photo] == nil) && (File.exists?(fpath) || File.exists?(hpath))
        FileUtils.mv(fpath, "#{subdir}completed/#{listfile}")
        FileUtils.mv(hpath, "#{subdir}completed/#{htmlfile}")
    end

    ## Create to do list of photos to take
    unless row[:item_num] == nil
        if row[:photo] == nil
            File.open("#{subdir}photos_req_#{sheetname}.txt", 'a+') { |f| f.puts(info) }
        end
    end
end
###
