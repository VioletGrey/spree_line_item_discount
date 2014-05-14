module Spree
  extend ActionView::Helpers::TagHelper
end

Spree::LineItem.class_eval do
  def item_total
    self.price
  end
end