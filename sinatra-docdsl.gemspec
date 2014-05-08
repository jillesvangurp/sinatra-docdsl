Gem::Specification.new do |s|
  s.name        = 'sinatra-docdsl'
  s.version     = '0.8.6'
  s.date        = '2014-02-28'
  s.summary     = "Documentation DSL for Sinatra"
  s.description = "A simple DSL for generating documentation for Sinatra REST applications"
  s.authors     = ["Jilles van Gurp"]
  s.email       = 'incoming@jillesvangurp.xom'
  s.files       = ["lib/docdsl.rb"]
  s.homepage    = 'https://github.com/jillesvangurp/sinatra-docdsl'
  s.license     = 'MIT'
  s.add_runtime_dependency "kramdown"
end
