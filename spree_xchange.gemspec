# -*- encoding: utf-8 -*-
# stub: spree_xchange 3.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "spree_xchange"
  s.version = "3.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["42team"]
  s.date = "2017-04-15"
  s.description = "bitrix mustDie"
  s.email = "info@42team.ru"
  s.files = ["app/assets", "app/assets/javascripts", "app/assets/javascripts/admin", "app/assets/javascripts/admin/spree_xchange.js", "app/assets/javascripts/store", "app/assets/javascripts/store/spree_xchange.js", "app/assets/stylesheets", "app/assets/stylesheets/admin", "app/assets/stylesheets/admin/spree_xchange.css", "app/assets/stylesheets/store", "app/assets/stylesheets/store/spree_xchange.css", "app/controllers", "app/controllers/exchange1c_controller.rb", "config/locales", "config/routes.rb", "lib/generators", "lib/generators/spree_xchange", "lib/generators/spree_xchange/install", "lib/generators/spree_xchange/install/install_generator.rb", "lib/spree_xchange", "lib/spree_xchange.rb", "lib/spree_xchange/engine.rb"]
  s.homepage = "http://spreecommerce.com"
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.requirements = ["none"]
  s.rubyforge_project = "spree_simple_blog"
  s.rubygems_version = "2.5.1"
  s.summary = "1c exchange module"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<spree_core>, [">= 3.0.0"])
      s.add_runtime_dependency(%q<capybara>, ["=> 1.0.1"])
      s.add_runtime_dependency(%q<factory_girl>, ["~> 2.6.4"])
      s.add_runtime_dependency(%q<ffaker>, [">= 0"])
      s.add_runtime_dependency(%q<rspec-rails>, ["~> 2.9"])
    else
      s.add_dependency(%q<spree_core>, [">= 3.0.0"])
      s.add_dependency(%q<capybara>, ["=> 1.0.1"])
      s.add_dependency(%q<factory_girl>, ["~> 2.6.4"])
      s.add_dependency(%q<ffaker>, [">= 0"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.9"])
    end
  else
    s.add_dependency(%q<spree_core>, [">= 3.0.0"])
    s.add_dependency(%q<capybara>, ["=> 1.0.1"])
    s.add_dependency(%q<factory_girl>, ["~> 2.6.4"])
    s.add_dependency(%q<ffaker>, [">= 0"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.9"])
  end
end
