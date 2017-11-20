
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rake-tasks-mysql/version'

Gem::Specification.new do |spec|
  spec.name          = 'rake-tasks-mysql'
  spec.version       = RakeTasksMysql::VERSION
  spec.authors       = ['Kieren Evans']
  spec.email         = ['kevans+rake-tasks-docker@inviqa.com']

  spec.summary       = 'MySQL tasks for Rake via Docker'
  spec.description   = 'MySQL tasks for Rake via Docker'
  spec.homepage      = ''
  spec.licenses = ['MIT']

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rake', '>= 10.0', '<= 13'
  spec.add_dependency 'rake-tasks-docker'
  spec.add_dependency 'slop', '~> 4.6.0'

  spec.add_development_dependency 'rspec', '~> 3.6'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'
end
