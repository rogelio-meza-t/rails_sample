source 'https://rubygems.org'

#comment

gem 'unicorn'
gem 'rails', '3.2.11'
gem 'pg'
gem 'haml'
gem 'devise'
gem 'jquery-rails'
#gem "rails_admin", "~> 0.1.1"
gem 'rails_admin', :git => "git://github.com/danbeaulieu/rails_admin.git"
#gem 'rails_admin'#, :path => "~/code/rails_admin"
gem 'monadic'
gem "paperclip", "~> 4.0"
gem 'aws-sdk', '~> 1.3.4'
#gem 'validates_timeliness', '~> 3.0'
gem 'dynamic_form'
gem 'delayed_job_active_record'
gem 'rails-i18n'
gem 'cocoon'
#gem 'globalize', '~> 3.0.0'
gem 'globalize3'
gem 'cancan'
gem 'paypal_adaptive'
#gem 'money-rails', :git => "git://github.com/danbeaulieu/money-rails.git" #:path => "~/code/money-rails" 
#gem 'money-rails', :path => "~/code/money-rails" 
#gem 'money-rails', :git => "git://github.com/RubyMoney/money-rails.git"
gem 'wicked'
gem 'country-select'
gem 'money-rails', :git => "git://github.com/danbeaulieu/money-rails.git" #:path => "~/code/money-rails" 
#gem 'money-rails', :path => "~/code/money-rails" 

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
  gem 'bootstrap-sass', '~> 2.2.2.0'
  gem 'bootstrap-datepicker-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'debugger'
end

group :test do
  gem 'rspec-rails',      :require => false
  gem 'cucumber-rails',   :require => false
  gem 'capybara',         :require => false
  #gem 'capybara-webkit',  :require => false
  gem 'database_cleaner', :require => false
  gem 'factory_girl_rails', '~> 3.0', :require => false
end

group :staging do
  gem "safety_mailer"
end

gem 'thin' #better web server
gem 'ckeditor_rails'
gem 'will_paginate'
