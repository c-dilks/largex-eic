#!/usr/bin/env ruby
## plot depolarization profile plots on the same canvas;
## run after analysis_depolarization.C -> postprocess_depolarization.C

# require 'pry'
require 'pycall/import'
r = PyCall.import_module 'ROOT'
r.gROOT.SetBatch true
r.gStyle.SetOptStat 0

## list of energies, and their settings
energyHash = {
  '5x41'   => { :color => r.kGreen+1 },
  '18x275' => { :color => r.kRed     },
}

## build hash of plots: { plotName => { energy => plot } }
plots = Hash.new
energyHash.keys.each do |energy|
  rootFile = r.TFile.new "out/depol.#{energy}.canvas.root", 'READ'
  plotList = Array.new
  PyCall.iterable(rootFile.GetListOfKeys).each do |key|
    if key.GetName.match? /^histos/
      plotName = key.GetName.split('_').find{|tok|tok.match?(/^depol/)}
      plots[plotName] = Hash.new if plots[plotName].nil?
      plots[plotName][energy] = key.ReadObj
    end
  end
end

## draw
plots.each do |plotName,energies|
  canvName = "#{plotName}_canv"
  canv = r.TCanvas.new canvName, canvName, 800, 600
  canv.SetLogx
  canv.SetGrid 1,1
  energies.each do |energy,plot|
    plot.SetLineColor energyHash[energy][:color]
    plot.SetTitle plot.GetTitle.split(',').first.sub(' distribution','')
    plot.GetXaxis.SetRangeUser 1, 1000
    plot.GetYaxis.SetRangeUser 0, 1.2 if plot.GetName.match?(/WA|CA/)
    plot.Draw 'SAME'
  end
  canv.Print "out/#{canvName}.png"
end
