Gem::Specification.new do |s|
  s.name        = 'snes_utils'
  s.version     = '0.3.0'
  s.executables = ['mini_assembler', 'png2snes', 'tmx2snes', 'vas']
  s.date        = '2019-10-27'
  s.summary     = 'SNES Utils'
  s.description = 'A collection of tools to create or edit SNES games'
  s.authors     = ['Vivien Bihl']
  s.email       = 'vivienbihl@gmail.com'
  s.files       = ['lib/png2snes/png2snes.rb',
                   'lib/mini_assembler/superfx/definitions.rb',
                   'lib/mini_assembler/spc700/definitions.rb',
                   'lib/mini_assembler/mini_assembler.rb',
                   'lib/mini_assembler/definitions.rb',
                   'lib/mini_assembler/wdc65816/definitions.rb',
                   'lib/tmx2snes/tmx2snes.rb',
                   'lib/snes_utils.rb',
                   'lib/vas/vas.rb',
                   'spec/spec_helper.rb',
                   'spec/spc700_spec.rb',
                   'spec/wdc65816_spec.rb',
                   'spec/vas_spec.rb',
                   'spec/mini_assembler_spec.rb']
  s.homepage    = 'https://rubygems.org/gems/snes_utils'
  s.metadata    = { 'source_code_uri' => 'https://github.com/vivi168/SNES_Utils' }
  s.license     = 'MIT'

  s.add_development_dependency 'rspec', '~> 3.12.0'
  s.add_development_dependency 'debug', '~> 1.8'

  s.add_runtime_dependency 'chunky_png', '~> 1.4.0'
  s.add_runtime_dependency 'rb-readline', '~> 0.5.5'
end
