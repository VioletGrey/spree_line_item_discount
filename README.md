Spree Line Item Discount
========================

Adds adjustments to Line Items for discounts.

Installation
------------

Add spree_line_item_discount to your Gemfile:

```ruby
gem 'spree_line_item_discount'
```

Then run
```shell
bundle install
```

Usage
-----

Create Promotion in Spree Admin. Add 'Create Line Item discount' action to your promotion.
Currently this only supports Flat Percent calculator.

Action creates adjustments on each line item + a cumulative adjustment on the Order.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle install
bundle exec rake test_app
bundle exec rspec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_line_item_discount/factories'
```

Copyright (c) 2014 Aditya Raghuwanshi, released under the New BSD License
