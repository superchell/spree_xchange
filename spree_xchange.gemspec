Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_xchange'
  s.version     = '3.2.0'
  s.summary     = '1c exchange module'
  s.description = 'bitrix mustDie'
  s.required_ruby_version = '>= 2.0.0'

  s.author            = '42team'
  s.email             = 'info@42team.ru'
  s.homepage          = 'http://spreecommerce.com'
  s.rubyforge_project = 'spree_simple_blog'

  s.files        = Dir['README.markdown', 'lib/**/*', 'app/**/*', 'config/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.has_rdoc = true

  s.add_dependency('spree_core', '>= 3.0.0')
  s.add_dependency('capybara', '1.0.1')
  s.add_dependency('factory_girl', '~> 2.6.4')
  s.add_dependency('ffaker')
  s.add_dependency('rspec-rails',  '~> 2.9')
end
