Gem::Specification.new do |s|
  s.name        = 'coue'
  s.version     = '0.0.0'
  s.date        = '2019-03-21'
  s.summary     = "geocoder based autocompletion/suggestion tool"
  s.description = "geocoder based autocompletion/suggestion tool"
  s.authors     = ["Antonio MalvaGomes"]
  s.email       = 'amalvag@g.clemson.edu'
  s.files       = ["lib/coue.rb"]
  s.executables << 'coue'
  s.add_runtime_dependency 'geocoder', '>= 1.2.0'
  s.homepage    =
    'http://rubygems.org/gems/coue'
  s.license       = 'MIT'
end
