# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :requisition_checkoutx_checkout, :class => 'RequisitionCheckoutx::Checkout' do
    project_id 1
    requisition_id 1
    item_id 1
    checkout_qty 10
    unit 'piece'
    checkout_by_id 1
    checkout_date Date.today
    brief_note 'some note'
    warehouse_item_id 1
    whs_string 'warehouse1'
  end
end
