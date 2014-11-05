require 'spec_helper'

module RequisitionCheckoutx
  describe CheckoutsController do
  
    before(:each) do
      controller.should_receive(:require_signin)
      controller.should_receive(:require_employee)
      
    end
    
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
      
      @i = FactoryGirl.create(:base_materialx_part)
      @i1 = FactoryGirl.create(:base_materialx_part, :name => 'a new name')
      @p = FactoryGirl.create(:ext_construction_projectx_project)
      @qi = FactoryGirl.build(:material_requisitionx_material_item, :item_id => @i.id)
      @qi1 = FactoryGirl.build(:material_requisitionx_material_item, :item_id => @i1.id, :name => 'a new name')
      @q = FactoryGirl.create(:material_requisitionx_requisition, :material_items => [@qi], :project_id => @p.id)
      @q1 = FactoryGirl.create(:material_requisitionx_requisition, :material_items => [@qi1], :project_id => @p.id, :approved => true)
        
    end
    
    render_views
    
    describe "GET 'index'" do
      it "returns all items" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "RequisitionCheckoutx::Checkout.scoped.order('created_at DESC')")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.create(:requisition_checkoutx_checkout, :requisition_id => @q.id, :item_id => @qi.id)
        q1 = FactoryGirl.create(:requisition_checkoutx_checkout, :requisition_id => @q1.id, :item_id => @qi1.id)
        get 'index', {:use_route => :requisition_checkoutx}
        assigns(:checkouts).should =~ [q, q1]
      end

      it "should only return the checkouts which belongs to the item_id" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "RequisitionCheckoutx::Checkout.scoped.order('created_at DESC')")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.create(:requisition_checkoutx_checkout, :item_id => @qi.id)
        q1 = FactoryGirl.create(:requisition_checkoutx_checkout, :item_id => @qi1.id)
        get 'index', {:use_route => :requisition_checkoutx, :item_id => @qi1.id}
        assigns(:checkouts).should =~ [q1]
      end
      
      it "should only return the checkouts which belongs to the project_id" do
        user_access = FactoryGirl.create(:user_access, :action => 'index', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "RequisitionCheckoutx::Checkout.scoped.order('created_at DESC')")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.create(:requisition_checkoutx_checkout, :requisition_id => @q.id, :item_id => @qi.id)
        q1 = FactoryGirl.create(:requisition_checkoutx_checkout, :requisition_id => @q1.id, :item_id => @qi1.id)
        get 'index', {:use_route => :requisition_checkoutx, :project_id => @p.id}
        assigns(:checkouts).should =~ [q1, q]
      end
    end
  
    describe "GET 'new'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'new', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        w = FactoryGirl.create(:petty_warehousex_item, :name => @qi.name, :item_spec => @qi.spec)
        get 'new', {:use_route => :requisition_checkoutx, :item_id => @qi.id}
        response.should be_success
      end
    end
  
    describe "GET 'create'" do
      it "returns redirect with success" do
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        w = FactoryGirl.create(:petty_warehousex_item, :name => @qi1.name, :item_spec => @qi1.spec)
        q = FactoryGirl.attributes_for(:requisition_checkoutx_checkout, :item_id => @qi1.id, :qty => 10)
        get 'create', {:use_route => :requisition_checkoutx, :item_id => @qi1.id, :checkout => q, :ids => [@qi1.id], :qtys => [2]}
        response.should redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Saved!")
        assigns(:checkout).out_qty.should eq(10)
        assigns(:item).stock_qty.should eq(90)
      end
      
      it "should render new with data error" do
        user_access = FactoryGirl.create(:user_access, :action => 'create', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.attributes_for(:requisition_checkoutx_checkout, :item_id => @qi1.id, :requested_qty => nil)
        get 'create', {:use_route => :requisition_checkoutx, :item_id => @qi1.id, :checkout => q}
        response.should render_template('new')
      end
    end
  
    describe "GET 'edit'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.create(:requisition_checkoutx_checkout, :item_id => @qi1.id, :last_updated_by_id => @u.id)
        get 'edit', {:use_route => :requisition_checkoutx, :id => q.id}
        response.should be_success
      end
    end
  
    describe "GET 'update'" do
      it "should redirect successfully" do
        user_access = FactoryGirl.create(:user_access, :action => 'update', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.create(:requisition_checkoutx_checkout, :item_id => @qi1.id, :last_updated_by_id => @u.id)
        get 'update', {:use_route => :requisition_checkoutx, :id => q.id, :checkout => {:brief_note => '20'}}
        response.should redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Updated!")
      end
      
    end
 
    describe "GET 'show'" do
      it "returns http success" do
        user_access = FactoryGirl.create(:user_access, :action => 'show', :resource =>'requisition_checkoutx_checkouts', :role_definition_id => @role.id, :rank => 1,
        :sql_code => "record.checkout_by_id == session[:user_id]")
        session[:user_id] = @u.id
        session[:user_privilege] = Authentify::UserPrivilegeHelper::UserPrivilege.new(@u.id)
        q = FactoryGirl.create(:requisition_checkoutx_checkout, :item_id => @qi1.id, :checkout_by_id => @u.id, :last_updated_by_id => @u.id)
        get 'show', {:use_route => :requisition_checkoutx, :id => q.id }
        response.should be_success
      end
    end
  
  end
end
