Gem::Specification.new do |spec|
  spec.name        = 'puppet-lint-class_parameter-check'
  spec.version     = '0.1.1'
  spec.licenses    = ['MIT']
  spec.summary     = "Puppet lint check for class parameters"
  spec.description = <<-EOF
   A puppet-lint plugin that checks class parameters. Class parameters should be split in two groups,
   the first group with no default values, the second group with default values. Both groups should be
   sorted alphabetically.
  EOF
  spec.authors     = ["Roelof Reitsma"]
  spec.email       = 'r.reitsma@coolblue.nl'
  spec.files       = Dir[
     'README.md',
     'LICENSE',
     'lib/**/*',
     'spec/**/*',
  ]
  spec.homepage    = 'https://github.com/ryreitsma/puppet-lint-class_parameter-check'
  spec.add_dependency             'puppet-lint', '~> 1.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rake'
end
