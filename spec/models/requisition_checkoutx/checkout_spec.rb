require 'spec_helper'

module RequisitionCheckoutx
  describe Checkout do
    it "should be OK" do
      c = FactoryGirl.create(:requisition_checkoutx_checkout)
      c.should be_valid
    end
    
    it "should reject nil unit" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, unit: nil)
      c.should_not be_valid
    end
    
    it "should reject 0 item_id" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, :item_id => 0)
      c.should_not be_valid
    end
    
    it "should reject nil in_checkout_date" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, :checkout_date => nil)
      c.should_not be_valid
    end
    
    it "should take nil checkout_qty" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, :checkout_qty => nil)
      c.should_not be_valid
    end
    
    it "should take 0 checkout_qty" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, :checkout_qty => 0)
      c.should be_valid
    end
    
    it "should reject non-digit requisition_id" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, :requisition_id => 'nil')
      c.should_not be_valid
    end
    
    it "should take non-digit requisition_id" do
      c = FactoryGirl.build(:requisition_checkoutx_checkout, :requisition_id => nil)
      c.should be_valid
    end
    
  end
end
