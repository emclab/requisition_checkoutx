require "requisition_checkoutx/engine"

module RequisitionCheckoutx
  mattr_accessor :item_class, :requisition_class, :warehouse_class, :project_class
  
  def self.requisition_class
    @@requisition_class.constantize
  end
  
  def self.item_class
    @@item_class.constantize
  end
  
  def self.warehouse_class
    @@warehouse_class.constantize
  end
  
  def self.project_class
    @@project_class.constantize
  end
end
