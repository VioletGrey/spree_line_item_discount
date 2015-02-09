Spree::OrderUpdater.class_eval do
  def choose_best_promotion_adjustment
    if best_promotion_adjustment = order.adjustments.promotion.eligible.reorder("amount ASC, created_at DESC").first
      other_promotions = order.adjustments.promotion.where("id NOT IN (?)", best_promotion_adjustment.id)
      other_promotions.update_all(eligible: false)
      other_line_item_promotions = order.line_item_adjustments.promotion.where("label NOT IN (?)", best_promotion_adjustment.label)
      other_line_item_promotions.update_all(eligible: false)
    end
  end

end