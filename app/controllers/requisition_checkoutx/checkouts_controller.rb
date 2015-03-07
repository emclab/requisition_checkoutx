require_dependency "requisition_checkoutx/application_controller"

module RequisitionCheckoutx
  class CheckoutsController < ApplicationController
    before_filter :require_employee
    before_filter :load_parent_record
    
    def index
      @title = t('Checkout Items')
      @checkouts = params[:requisition_checkoutx_checkouts][:model_ar_r]
      @checkouts = @checkouts.where(:whs_string => @whs_string) if @whs_string
      @checkouts = @checkouts.where(:project_id => @project.id) if @project
      @checkouts = @checkouts.where(:requisition_id => @requisition.id) if @requisition
      @checkouts = @checkouts.where(:item_id => @item.id) if @item
      @checkouts = @checkouts.page(params[:page]).per_page(@max_pagination)
      @erb_code = find_config_const('checkout_index_view', 'requisition_checkoutx')
    end
  
    def new
      @title = t('New Checkout Item')
      @checkout = RequisitionCheckoutx::Checkout.new()
      @project_id = RequisitionCheckoutx.requisition_class.find_by_id(@item.requisition_id).project_id 
      @item_in_stock = RequisitionCheckoutx.warehouse_class.where('name = ? AND item_spec = ?', @item.name, @item.spec).order('created_at')
      @erb_code = find_config_const('checkout_new_view', 'requisition_checkoutx')
    end
  
    def create
      requisition_item_id = params[:save].keys[0].to_i
      @item = RequisitionCheckoutx.item_class.find_by_id(requisition_item_id)
      requisition = RequisitionCheckoutx.requisition_class.find_by_id(@item.requisition_id)
      if check_stock_qty(params['ids'], params['out_qtys'], @item.qty)  #check qty before start save process
        #transaction_error = false
        RequisitionCheckoutx::Checkout.transaction do
          begin
            params['ids'].each do |id| 
              params['out_qtys'].each do |qty| #ids passed in as a string of 'id'
                stock_item = RequisitionCheckoutx.warehouse_class.find_by_id(id.to_i)
                stock_item.whs_item_id = id
                stock_item.stock_qty = stock_item.stock_qty - qty.to_i
                #stock_item.checkouted_by_id = session[:user_id]
                #stock_item.last_updated_by_id = session[:user_id]
                stock_item.save!
                #create one checkout for each stock item
                checkout = RequisitionCheckoutx::Checkout.new(params[:checkout], :as => :role_new)
                checkout.checkout_qty = qty.to_i
                checkout.warehouse_item_id = stock_item.id
                checkout.whs_string = stock_item.whs_string if stock_item.whs_string.present?
                checkout.unit = @item.unit
                checkout.checkout_date = Date.today
                checkout.item_id = requisition_item_id
                checkout.requisition_id = @item.requisition_id
                checkout.project_id = requisition.project_id
                checkout.last_updated_by_id = session[:user_id]
                checkout.checkout_by_id = session[:user_id]
                checkout.save!
              
              end unless params['out_qtys'].blank?
            end unless params['ids'].blank?
            #successful, redirect
            redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Saved!")
          rescue => e
            @item_in_stock = RequisitionCheckoutx.warehouse_class.where('name = ? AND item_spec = ?', @item.name, @item.spec).order('created_at')
            @erb_code = find_config_const('checkout_new_view', 'requisition_checkoutx')
            flash[:notice] = t('Data Error. Not Saved!')
            #transaction_error = true
            render 'new'
            raise ActiveRecord::Rollback # it calls Rollback to the database 
          end  #begin
        end  #transaction
      else #check_stock_qty
        @erb_code = find_config_const('checkout_new_view', 'requisition_checkoutx')
        @item_in_stock = RequisitionCheckoutx.warehouse_class.where('name = ? AND item_spec = ?', @item.name, @item.spec).order('created_at')
        flash[:notice] = t('Stock Qty Not Enough or Missing Data')
        render 'new'  
      end #check_stock_qty
    end 
  
    def edit
      @title = t('Update Checkout Item')
      @checkout = RequisitionCheckoutx::Checkout.find_by_id(params[:id])
      @item_id = params[:checkout][:item_id] if params[:checkout].present? && params[:checkout][:item_id].present?
      @erb_code = find_config_const('checkout_edit_view', 'requisition_checkoutx')
    end
  
    def update
      @checkout = RequisitionCheckoutx::Checkout.find_by_id(params[:id])
      @checkout.last_updated_by_id = session[:user_id]
      if @checkout.update_attributes(params[:checkout], :as => :role_update)
        redirect_to URI.escape(SUBURI + "/authentify/view_handler?index=0&msg=Successfully Updated!")
      else
        #@qty_unit = find_config_const('piece_unit').split(',').map(&:strip)
        @erb_code = find_config_const('checkout_edit_view', 'requisition_checkoutx')
        flash[:notice] = t('Data Error. Not Updated!')
        render 'edit'        
      end
    end
    
    def show
      @title = t('Checkout Item Info')
      @checkout = RequisitionCheckoutx::Checkout.find_by_id(params[:id])
      @erb_code = find_config_const('checkout_show_view', 'requisition_checkoutx')
    end

    protected
    def load_parent_record
      @item = RequisitionCheckoutx.item_class.find_by_id(params[:item_id]) if params[:item_id].present?
      @item = RequisitionCheckoutx.item_class.find_by_id(RequisitionCheckoutx::Checkout.find_by_id(params[:id]).item_id) if params[:id].present?
      @requisition = RequisitionCheckoutx.requistion_class.find_by_id(params[:requisition_id]) if params[:requisition_id].present?
      @project = RequisitionCheckoutx.project_class.find_by_id(@requisition.project_id) if @requisition
      @project = RequisitionCheckoutx.project_class.find_by_id(params[:project_id]) if params[:project_id].present?
      @whs_string = params[:whs_string].strip if params[:whs_string].present?
    end
    
    #return false if requested qty > stock qty. Otherwise return tru
    def check_stock_qty(ids, qtys, requisition_qty)
      return false if ids.blank? or qtys.blank? or ids.size != qtys.size
      return false if requisition_qty != qtys.map{|x| x.to_i}.reduce(:+)    #false if requisition qty and checkout qty NOT equal
      ids.each do |id| 
        qtys.each do |qty|
          stock_item = RequisitionCheckoutx.warehouse_class.find_by_id(id.to_i)
          if stock_item.stock_qty < qty.to_i or qty.blank? or id.blank?
            return false
          end
        end
      end 
      return true    
    end
    
  end
end
