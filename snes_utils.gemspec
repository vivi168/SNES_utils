Gem::Specification.new do |s|
  s.name        = 'snes_utils'
  s.version     = '0.1.0'
  s.executables = ['mini_assembler', 'png2snes', 'tmx2snes']
  s.date        = '2019-10-27'
  s.summary     = 'SNES Utils'
  s.description = 'A collection of tools to create or edit SNES games'
  s.authors     = ['Vivien Bihl']
  s.email       = 'vivienbihl@gmail.com'
  s.files       = ['lib/snes_utils.rb']
  s.homepage    = 'https://rubygems.org/gems/snes_utils'
  s.metadata    = { 'source_code_uri' => 'https://github.com/vivi168/SNES_Utils' }
  s.license     = 'MIT'

  s.add_development_dependency 'byebug', '~> 11.0'
  s.add_development_dependency 'rspec', '~> 3.9'

  s.add_runtime_dependency 'chunky_png', '~> 1.3'
  s.add_runtime_dependency 'nokogiri', '~> 1.10'
  s.add_runtime_dependency 'rb-readline', '~> 0.5'
end
