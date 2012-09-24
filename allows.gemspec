Gem::Specification.new do |s|
  s.name        = 'allows'
  s.version     = '0.1.0'
  s.date        = '2012-09-24'
  s.summary     = "Simple Authorization library"
  s.description = "Simple Authorization for Rails"
  s.authors     = ["Jose Goncalves"]
  s.email       = 'zetoeu@gmail.com'
  s.homepage    = 'http://github.com/zeto/allows'
  s.files = Dir["**/*"] - Dir["*.gem"] - ["Gemfile.lock"]

  s.require_paths = ["lib"]  
  s.add_development_dependency "turn"
  s.add_development_dependency "debugger"
  s.add_development_dependency "rake"
end
