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
          if order.promotion_credit_exists?(self)
            if order.line_items.count == order.line_item_adjustments.count
              return
            else
              self.create_line_item_adjustments("#{Spree.t(:promotion)} (#{promotion.name})", order)
            end
          else
            self.create_adjustment("#{Spree.t(:promotion)} (#{promotion.name})", order)
          end
        end

        def compute_amount(calculable)
          amount = self.calculator.compute(calculable).to_f.abs
          [calculable.item_total, amount].min * -1
        end

        def create_line_item_adjustments(label, order, mandatory=false)
          order.line_items.each do |line_item|
            if line_item.adjustments.eligible.promotion.blank?
              amount = compute_amount(line_item)
              line_item.adjustments.create(
                amount: amount,
                source: line_item,
                originator: self,
                label: label,
                mandatory: mandatory
              )
            end
          end
        end

        def create_adjustment(label, order, mandatory=false)
          order.line_items.each do |line_item|
            amount = compute_amount(line_item)
            line_item.adjustments.create(
              amount: amount,
              source: line_item,
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

        def update_adjustment(adjustment, calculable)
          calculable = calculable.to_package if calculable.is_a?(Spree::Shipment)
          if calculable.is_a?(Spree::Order)
            calculable.line_item_adjustments.each do |adj|
              adj.update_column(:amount, compute_amount(adj.source))
            end
          end
          adjustment.update_column(:amount, compute_amount(calculable))
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