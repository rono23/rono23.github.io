+++
title = "Upgrading to Rails 5"
date = "2016-07-02"
tags = ["rails"]
aliases = ["/posts/upgrading-to-rails-5/"]
+++

There are lots of changes, so I just picked up some here.

## ActiveRecord

`belongs_to` required by default.

```
# config/initializers/new_framework_defaults.rb
Rails.application.config.active_record.belongs_to_required_by_default = true

# app/models/post.rb
- belongs_to :user, required: true
+ belongs_to :user
```

But you need to care about it because of other gems. It sometimes doesn't work if one of gems is using a hook like `ActiveRecord::Base.extend`, `ActiveRecord::Base.send :include` etc intead of `ActiveSupport.on_load(:active_record)`.
[#rails/rails#23589](https://github.com/rails/rails/issues/23589)

## ActionMailer

Change your mailers to inherit from your new `ApplicationMailer`.

```
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@example.com'
  layout 'mailer' #=> app/views/layouts/mailer.html.erb or mailer.txt.erb
end
```

## Default values in initializers

Setup the default locale, generators etc from an initializer instead of `config/application.rb`

```
# config/initializers/locale.rb
Rails.application.config.i18n.available_locales = [:en, :ja]
Rails.application.config.i18n.default_locale = :en

# config/initializers/generators.rb
Rails.application.config.generators do |g|
  g.stylesheet_engine :sass
  g.template_engine :slim
  ...
end
```

But you shouldn't assign some values such as `time_zone` in an initializer. Because `Rails.application.config.time_zone` will work, but `Time.zone` won't. [Time.zone_default](https://github.com/rails/rails/blob/791bdf6fb350b5cb272e4277c1b2b3d04beb7a35/activesupport/lib/active_support/railtie.rb#L25) is assgined before the initializer.

> In general, configuration specific to the application object needs to go either in config/application.rb or in config/environments/#{Rails.env}.rb, you can't just assign to an arbitrary config point in config/initializers and expect it to work.
https://github.com/rails/rails/issues/24748#issuecomment-216317145

```
# config/application.rb
module Foo
  class Application < Rails::Application
    config.time_zone = 'UTC'
    config.paths.add 'lib', eager_load: true
  end
end
```

## Quiet assets

You don't need [quiet_assets](https://github.com/evrone/quiet_assets) gem finally! Logger output is suppressed using `Rails.application.config.assets.prefix` path to match.
[rails/rails#25351](https://github.com/rails/rails/pull/25351), [rails/sprockets-rails#355](https://github.com/rails/sprockets-rails/pull/355/files)

```
# config/environments/development.rb
# Suppress logger output for asset requests.
config.assets.quiet = true
```

## Related links

- [Ruby on Rails 5.0 Release Notes](http://guides.rubyonrails.org/5_0_release_notes.html)
- [A Guide for Upgrading Ruby on Rails](http://guides.rubyonrails.org/upgrading_ruby_on_rails.html)
- [Rails 5 | BigBinary Blog](http://blog.bigbinary.com/categories/Rails-5/)

