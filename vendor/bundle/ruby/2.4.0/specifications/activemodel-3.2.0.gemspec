# -*- encoding: utf-8 -*-
# stub: activemodel 3.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "activemodel".freeze
  s.version = "3.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["David Heinemeier Hansson".freeze]
  s.date = "2012-01-20"
  s.description = "A toolkit for building modeling frameworks like Active Record and Active Resource. Rich support for attributes, callbacks, validations, observers, serialization, internationalization, and testing.".freeze
  s.email = "david@loudthinking.com".freeze
  s.homepage = "http://www.rubyonrails.org".freeze
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7".freeze)
  s.rubygems_version = "2.6.11".freeze
  s.summary = "A toolkit for building modeling frameworks (part of Rails).".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>.freeze, ["= 3.2.0"])
      s.add_runtime_dependency(%q<builder>.freeze, ["~> 3.0.0"])
    else
      s.add_dependency(%q<activesupport>.freeze, ["= 3.2.0"])
      s.add_dependency(%q<builder>.freeze, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<activesupport>.freeze, ["= 3.2.0"])
    s.add_dependency(%q<builder>.freeze, ["~> 3.0.0"])
  end
end
