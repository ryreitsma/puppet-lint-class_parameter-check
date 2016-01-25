# Puppet-lint plugin for checking class parameters
A puppet-lint plugin that checks class parameters. Class parameters should be split in two groups, the first group with no default values, the second group with default values. Both groups should be sorted alphabetically.

## Installation
To use this plugin, add the following like to the Gemfile in your Puppet code base and run `bundle install`.

```ruby
gem 'puppet-lint-tutorial-check'
```
## Usage
This plugin provides a new check to `puppet-lint`.
