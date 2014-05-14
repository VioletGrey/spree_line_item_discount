require 'spec_helper'

describe Spree::Promotion::Actions::CreateLineItemAdjustment do
  let(:order) { create(:order_with_line_items) }
  let(:promotion) { create(:promotion) }
  let(:action) { Spree::Promotion::Actions::CreateLineItemAdjustment.new }

  context '#perform' do
    before do
      action.calculator = Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: "10")
      promotion.promotion_actions = [action]
      action.stub(:promotion => promotion)
    end

    it "should create a discount with correct negative amounts" do
      action.perform(:order => order)
      promotion.credits_count.should == 1 + order.line_items.size
      order.line_item_adjustments.count.should == order.line_items.size
      order.adjustments.count.should == 1
      order.adjustments.first.amount.to_i.should == -5
    end

    it "should not create a discount when order already has one from this promotion" do
      action.perform(:order => order)
      action.perform(:order => order)
      promotion.credits_count.should == 1 + order.line_items.size
    end
  end

  context "#destroy" do
    before(:each) do
      promotion.promotion_actions = [action]
    end

    context "when order is not complete" do
      it "should not keep the adjustment" do
        action.perform(:order => order)
        action.destroy
        order.line_item_adjustments.count.should == 0
        order.adjustments.count.should == 0
      end
    end

    context "when order is complete" do
      before(:each) do
        order.update_attributes(state: 'complete')
        action.perform(:order => order)
        action.destroy
        order.reload
      end

      it "should keep the adjustment" do
        order.line_item_adjustments.count.should == order.line_items.size
        order.adjustments.count.should == 1
      end

      it "should nullify the adjustment originator" do
        order.line_item_adjustments.first.originator.should be_nil
        order.adjustments.first.originator.should be_nil
      end
    end
  end

  context "#compute_amount" do
    before do
      action.calculator = Spree::Calculator::FlatPercentItemTotal.create(preferred_flat_percent: "10")
    end

    it "should always return a negative amount" do
      order.line_items.first.stub(:item_total => 1000)
      action.calculator.stub(:compute => -200)
      action.compute_amount(order.line_items.first).to_i.should == -200
      action.calculator.stub(:compute => 300)
      action.compute_amount(order.line_items.first).to_i.should == -300
    end

    it "should not return an amount that exceeds item's item_total" do
      order.line_items.first.stub(:item_total => 1000)
      action.calculator.stub(:compute => 900)
      action.compute_amount(order.line_items.first).to_i.should == -900
      action.calculator.stub(:compute => 1000)
      action.compute_amount(order.line_items.first).to_i.should == -1000
      action.calculator.stub(:compute => 1200)
      action.compute_amount(order.line_items.first).to_i.should == -1000
    end
  end
end