#!/usr/bin/env ruby
def h()
  ENV['HOME']
end

def _docs()
  File.join(h, 'Dropbox', 'Documents')
end

def _versicherung()
  File.join(_docs, '_life', 'versicherung')
end

def _p()
  File.join(_docs, '_projects')
end

def d()
  File.join _p, '_d'
end

def r()
  File.join _p, '_r'
end

def ssd()
  "/media/ssd"
end

def audicgw()
  "/home/gizmo/_projects/audicgw"
end

def audi()
  "/media/more/audi"
end
def hcp5()
  "/media/more/hcp5"
end
def sync()
  "#{h}/Sync"
end

def repo_manifest_projects()
  require 'rexml/document'
  xml = File.read(File.join(h, '.repo', 'manifests', 'default.xml'))
  doc = REXML::Document.new(xml)
  doc.elements.collect('manifest/project') { |p| File.join(h, p.attributes['path']) }
end

projects =
  repo_manifest_projects +
  Dir.glob("#{h}/Dropbox/Documents/_projects/*") +
  Dir.glob("#{h}/Dropbox/Documents/_projects/_pi/*") +
  Dir.glob("#{sync}/projects/_d/active/*") +
  Dir.glob("#{sync}/projects/_d/external/*") +
  Dir.glob("#{sync}/projects/*") +
  Dir.glob("#{sync}/projects/*") +
  Dir.glob("#{sync}/configs/*") +
  Dir.glob("#{sync}/projects/_rust/*") +
  [
    "#{h}/ESRLabs/quantum/workspace/",
    "#{h}/ESRLabs/quantum/workspace/mosaic-core-rs",
    "#{h}/_projects/IT",
    "#{h}/_projects/IT/VMWare Stuff",
    "#{_p}/_android",
    "#{_p}/monica-runs",
    "#{_p}/armillotta-it/monica",
    "#{_p}/ergodox",
    "#{_p}/nutrition-density",
    "#{_p}/server-monitor",
    "#{_p}/HoningYourSkills",
    "#{_p}/dotstar",
    "#{sync}/projects/sg4d/examples/viewed",
    "#{ssd}/mkd",
    "#{_p}/dotstar/sdrip",
    "#{d}",
    "#{_versicherung}",
    "#{_docs}/_projects/_ruby/teams",
  ]

puts projects.join("\n")
