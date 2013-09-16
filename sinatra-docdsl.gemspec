Gem::Specification.new do |s|
  s.name        = 'sinatra-docdsl'
  s.version     = '0.7.0'
  s.date        = '2013-08-30'
  s.summary     = "Documentation DSL for Sinatra"
  s.description = "A simple DSL for documenting Sinatra apps and generating a /doc endpoint in a sinatra resource"
  s.authors     = ["Jilles van Gurp"]
  s.email       = 'incoming@jillesvangurp.xom'
  s.files       = ["lib/docdsl.rb"]
  s.homepage    = 'https://github.com/jillesvangurp/sinatra-docdsl'
  s.license     = 'MIT'
  s.add_runtime_dependency "kramdown"
end