# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'acts_as_binary_tree/version'

Gem::Specification.new do |s|
  s.name        = 'acts_as_binary_tree'
  s.version     = ActsAsBinaryTree::VERSION
  s.authors     = ['Joao Gabriel Fraga']
  s.email       = ['jgfraga@gmail.com']
  s.homepage    = 'https://github.com/joaofraga/acts_as_binary_tree'
  s.summary     = %q{Provides a binary tree behaviour to active_record models.}
  s.description = %q{A gem that adds simple support for organizing ActiveRecord models into binary tree relationships.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.rdoc_options  = ["--charset=UTF-8"]

  s.add_dependency "activerecord", ">= 3.0.0"

  # Dependencies (installed via 'bundle install')...
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rdoc"
end