module Spree
  class Promotion
    module Actions
      class CreateLineItemAdjustment < PromotionAction
        include Spree::Core::CalculatedAdjustments

        has_many :adjustments, as: :originator

        delegate :eligible?, to: :promotion

        before_validation :ensure_action_has_calculator
        before_destroy :deals_with_adjustments

        def perform(options = {})
          order = options[:order]
          return if order.promotion_credit_exists?(self)
          self.create_adjustment("#{Spree.t(:promotion)} (#{promotion.name})", order)
        end

        def compute_amount(calculable)
          amount = self.calculator.compute(calculable).to_f.abs
          [calculable.item_total, amount].min * -1
        end

        def create_adjustment(label, order, mandatory=false)
          order.line_items.each do |line_item|
            amount = compute_amount(line_item)
            line_item.adjustments.create(
              amount: amount,
              source: order,
              originator: self,
              label: label,
              mandatory: mandatory
            )
          end
          adj = order.line_item_adjustment_totals[label]
          unless adj.blank?
            order.adjustments.create(
              amount: adj.money.to_f,
              source: order,
              originator: self,
              label: label,
              mandatory: mandatory
            )
          end
        end

        private
        def ensure_action_has_calculator
          return if self.calculator
          self.calculator = Calculator::FlatPercentItemTotal.new
        end

        def deals_with_adjustments
          self.adjustments.each do |adjustment|
            if adjustment.source.complete?
              adjustment.originator = nil
              adjustment.save
            else
              adjustment.destroy
            end
          end
        end
      end
    end
  end
end