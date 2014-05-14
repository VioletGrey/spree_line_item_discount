# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_line_item_discount'
  s.version     = '2.1.2'
  s.summary     = 'Add Discount to Line Items'
  s.description = 'Promotion Action for adding Discounts at the line item level'
  s.required_ruby_version = '>= 2.0.0'

  s.author    = 'Aditya Raghuwanshi'
  s.email     = 'adi.version1@gmail.com'
  s.homepage  = 'https://github.com/kitwalker12/spree_line_item_discount'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  gem.add_dependency 'money', '~> 5.1.1'
  s.add_dependency 'spree_core', '2.1.2'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
