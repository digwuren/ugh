Gem::Specification.new do |s|
  s.name = 'ugh'
  s.version = '1.0.0'
  s.date = '2014-12-22'
  s.homepage = 'https://github.com/digwuren/ugh'
  s.summary = 'Attributed exceptions in nested context domains'
  s.author = 'Andres Soolo'
  s.email = 'dig@mirky.net'
  s.files = File.read('Manifest.txt').split(/\n/)
  s.license = 'GPL-3'
  s.description = <<EOD
Ugh provides infrastructure for attributed error messages and
for (re)attributing these in accordance with dynamically scoped
nestable context domains.
EOD
  s.has_rdoc = false
  s.add_development_dependency 'maui', '~> 3.1.0'
end
