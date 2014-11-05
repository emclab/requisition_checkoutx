module RequisitionCheckoutx
  class Checkout < ActiveRecord::Base
    attr_accessor :last_updated_by_name, :checkout_by_name, :field_changed, :request_date, :requested_by_name, :project_name
    attr_accessible :brief_note, :checkout_by_id, :checkout_date, :checkout_qty, :item_id, :last_updated_by_id, :requisition_id, :unit, :wf_state, 
                    :field_changed, :requested_by_name, :request_date, :whs_string, :warehouse_item_id, :whs_string, :project_id,
                    :project_name,
                    :as => :role_new
    attr_accessible :brief_note, :checkout_by_id, :checkout_date, :checkout_qty, :last_updated_by_id, :unit, :wf_state, :project_id,
                    :field_changed, :request_date, :requested_by_name, :warehouse_item_id, :project_name,
                    :as => :role_update
    
    attr_accessor :start_date_s, :end_date_s, :time_frame_s, :name_s, :checkout_by_id_s, :item_spec_s, :item_id_s, :requisition_id_s, :project_id_s, :requested_by_s,
                  :whs_string_s   
    attr_accessible :start_date_s, :end_date_s, :time_frame_s, :name_s, :checkout_by_id_s, :item_spec_s, :item_id_s, :requisition_id_s, :project_id_s, :requested_by_s,
                    :whs_string_s,
                    :as => :role_search_stats
                    
    belongs_to :last_updated_by, :class_name => 'Authentify::User'
    belongs_to :requisition, :class_name => RequisitionCheckoutx.requisition_class.to_s
    belongs_to :checkout_by, :class_name => 'Authentify::User'
    belongs_to :item, :class_name => RequisitionCheckoutx.item_class.to_s
    belongs_to :warehouse_item, :class_name => RequisitionCheckoutx.warehouse_class.to_s
    belongs_to :project, :class_name => RequisitionCheckoutx.project_class.to_s
    
    validates :unit, :checkout_date, :presence => true
    validates :item_id, :checkout_by_id, :numericality => {:only_integer => true, :greater_than => 0}
    validates :checkout_qty, :presence => true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
    validates :requisition_id, :numericality => {:only_integer => true, :greater_than => 0}, :if => 'requisition_id.present?'
    validate :dynamic_validate 
    
    def dynamic_validate
      wf = Authentify::AuthentifyUtility.find_config_const('dynamic_validate', 'requisition_checkoutx')
      eval(wf) if wf.present?
    end        
  end
end
