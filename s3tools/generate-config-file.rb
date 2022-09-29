#!/usr/bin/env ruby
# generate a config file, from a set of `list` files
# this script is generally called by `s3tools/make-*-config.sh` scripts

require 'pp'

# constants
CrossingAngle = -25 # default beam crossing angle [mrad]

# usage guide
if ARGV.length < 3
  puts "ERROR: not enough arguments" if ARGV.length > 0
  puts """
  USAGE: #{$0} [config_file] [energy] [list_files...]

  [config_file]:   name of output config file
  [energy]:        beam energy, such as 5x41 or 10x100
  [list_files...]: list of \"list files\", generated by one of the
                   `s3tools/generate-*-list.sh` scripts
  """
  exit 2
end

# parse arguments
globalSettings = Hash.new
configFile = ARGV[0]
globalSettings[:eleBeamEn], globalSettings[:ionBeamEn] = ARGV[1].split 'x'
listFiles = ARGV[2..]
globalSettings[:crossingAngle] = CrossingAngle
puts "="*50, "generating config file".upcase, "="*50
puts "configFile: #{configFile}"
pp "globalSettings:", globalSettings
pp "listFiles:", listFiles

# parse list files, forming groups keyed by `[Q2min,Q2max]`
groupSettings = Hash.new
listFiles.map{ |f| File.open(f,'r').readlines }.each do |listFileLines|
  # parse the list files
  listFileLines.each do |line|
    # tokenize; these must be consistent with `generate-*.list.sh` columns
    rootFile, crossSection, q2min, q2max = line.split.map do |token|
      token.match?(/\.root$/) ? token : token.to_f # assume `token` is a number, if not a ROOT file
    end
    # create a unique key for this Q2 range
    q2key = "#{q2min},#{q2max}"
    # fill `groupSettings[q2key]`
    unless groupSettings.has_key? q2key
      groupSettings[q2key]                = Hash.new
      groupSettings[q2key][:files]        = Array.new
      groupSettings[q2key][:q2min], groupSettings[q2key][:q2max] = q2key.split(',').map &:to_f
      groupSettings[q2key][:crossSection] = crossSection.to_f
    end
    groupSettings[q2key][:files] << rootFile
    puts "ERROR: conflicting cross section" if crossSection!=groupSettings[q2key][:crossSection]
  end
end
# puts "\ngroupSettings:"
# pp groupSettings

# sort groups by decreasing cross section
groupSettingsSorted = groupSettings.sort_by{ |s| s.last[:crossSection] }.reverse.to_h
puts "\ngroupSettings, sorted by cross section:"
pp groupSettingsSorted

# assume the largest cross section is the total cross section (may not always be true!)
globalSettings[:totalCrossSection] = groupSettings.values.map{ |s| s[:crossSection] }.max

# start config file
configOut = File.open configFile, 'w'
writeSetting = Proc.new{ |k,v| configOut.puts ":#{k} #{v}" }
configOut.puts "\#"*60
configOut.puts "\# configuration file, auto-generated by:".upcase
configOut.puts "\#   #{$0} #{ARGV.join(' ')}"
configOut.puts "\#"*60

# write global settings
configOut.puts """
\# Global Settings
\# ===============
"""
globalSettings.each{ |k,v| writeSetting.call k, v }

# write group settings
configOut.puts """
\# Group Settings   | NOTE: they must be sorted by increasing strictness
\# ==============   | of Q2 cuts, or at least by decreasing cross section
"""
groupSettingsSorted.values.each_with_index do |settingsHash,i|
  configOut.puts "\n\# Q2 range #{i+1}"
  settingsHash.each do |key,value|
    unless key == :files
      next if key==:q2max and value==0.0  # skip case with no q2max
      writeSetting.call key, value
    end
  end
  settingsHash[:files].each{ |f| configOut.puts f }
end

# cleanup
configOut.close
puts """
#{"="*50}
CONFIG FILE: #{configFile}
#{"="*50}
"""
system "cat #{configFile}"
puts "="*50, "PRODUCED CONFIG FILE #{configFile}\n\n"
