Gem::Specification.new do |s|
  s.name        = 'allows'
  s.version     = '0.0.1'
  s.date        = '2012-09-17'
  s.summary     = "Simple Authorization library"
  s.description = "Simple Authorization for Rails"
  s.authors     = ["Jose Goncalves"]
  s.email       = 'zetoeu@gmail.com'
  s.homepage    = 'http://rubygems.org/gems/control'
  s.files = Dir["**/*"] - Dir["*.gem"] - ["Gemfile.lock"]

  s.require_paths = ["lib"]  
  s.add_development_dependency "actionpack"
  s.add_development_dependency "turn"
  s.add_development_dependency "debugger"
  s.add_development_dependency "rake"
end
