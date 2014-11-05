require 'spec_helper'

describe "LinkTests" do
  describe "GET /requisition_checkoutx_link_tests" do
    mini_btn = 'btn btn-mini '
    ActionView::CompiledTemplates::BUTTONS_CLS =
        {'default' => 'btn',
         'mini-default' => mini_btn + 'btn',
         'action'       => 'btn btn-primary',
         'mini-action'  => mini_btn + 'btn btn-primary',
         'info'         => 'btn btn-info',
         'mini-info'    => mini_btn + 'btn btn-info',
         'success'      => 'btn btn-success',
         'mini-success' => mini_btn + 'btn btn-success',
         'warning'      => 'btn btn-warning',
         'mini-warning' => mini_btn + 'btn btn-warning',
         'danger'       => 'btn btn-danger',
         'mini-danger'  => mini_btn + 'btn btn-danger',
         'inverse'      => 'btn btn-inverse',
         'mini-inverse' => mini_btn + 'btn btn-inverse',
         'link'         => 'btn btn-link',
         'mini-link'    => mini_btn +  'btn btn-link'
        }
    
    before(:each) do
      FactoryGirl.create(:engine_config, :engine_name => nil, :engine_version => nil, :argument_name => 'piece_unit', :argument_value => 'piece, set, kg')
      @pagination_config = FactoryGirl.create(:engine_config, :engine_name => nil, :engine_version => nil, :argument_name => 'pagination', :argument_value => 30)
      z = FactoryGirl.create(:zone, :zone_name => 'hq')
      type = FactoryGirl.create(:group_type, :name => 'employee')
      ug = FactoryGirl.create(:sys_user_group, :user_group_name => 'ceo', :group_type_id => type.id, :zone_id => z.id)
      @role = FactoryGirl.create(:role_definition)
      ur = FactoryGirl.create(:user_role, :role_definition_id => @role.id)
      ul = FactoryGirl.build(:user_level, :sys_user_group_id => ug.id)
      @u = FactoryGirl.create(:user, :user_levels => [ul], :user_roles => [ur])
      
      ua1 = FactoryGirl.create(:user_access, :action => 'index', :resource => 'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "RequisitionCheckoutx::Checkout.order('created_at DESC')")
      ua1 = FactoryGirl.create(:user_access, :action => 'new_checkout', :resource => 'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      ua1 = FactoryGirl.create(:user_access, :action => 'new_checkout_result', :resource => 'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      ua1 = FactoryGirl.create(:user_access, :action => 'create', :resource => 'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      ua1 = FactoryGirl.create(:user_access, :action => 'update', :resource => 'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      user_access = FactoryGirl.create(:user_access, :action => 'show', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
      :sql_code => "")
      
      @i = FactoryGirl.create(:base_materialx_part)
      @i1 = FactoryGirl.create(:base_materialx_part, :name => 'a new name')
      @p = FactoryGirl.create(:ext_construction_projectx_project)
      @qi = FactoryGirl.build(:material_requisitionx_material_item, :item_id => @i.id)
      @qi1 = FactoryGirl.build(:material_requisitionx_material_item, :item_id => @i1.id, :name => 'a new name')
      @q = FactoryGirl.create(:material_requisitionx_requisition, :material_items => [@qi], :project_id => @p.id)
      @q1 = FactoryGirl.create(:material_requisitionx_requisition, :material_items => [@qi1], :project_id => @p.id, :approved => true)
      w = FactoryGirl.create(:petty_warehousex_item, :name => @qi.name, :item_spec => @qi.spec, :in_qty => 2, :stock_qty => 2)
      w = FactoryGirl.create(:petty_warehousex_item, :name => @qi.name, :item_spec => @qi.spec, :in_qty => 10, :stock_qty => 10)
                
      visit '/'
      #save_and_open_page
      fill_in "login", :with => @u.login
      fill_in "password", :with => 'password'
      click_button 'Login'
        
    end
    
    it "works! (now write some real specs)" do
      q = FactoryGirl.create(:requisition_checkoutx_checkout, :requisition_id => @q.id, :item_id => @qi.id)
      visit checkouts_path(:item_id => @qi.id, :project_id => @p.id, :method => :get)
      #save_and_open_page
      page.should have_content('Checkout Items')
      click_link 'New Checkout'
      save_and_open_page
      #page.check('out_qtys_')
      find(:css, "#ids_[value='1']").set(true)
      fill_in('out_qtys_', :with => 2, match: :first)
      click_link 'Save'
    end
  end
end
