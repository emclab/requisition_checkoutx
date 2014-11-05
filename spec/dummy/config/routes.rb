Rails.application.routes.draw do

  mount RequisitionCheckoutx::Engine => "/requisition_checkoutx"
  mount Authentify::Engine => "/authentify"
  mount Commonx::Engine => "/commonx"
  mount Searchx::Engine => '/search'
  mount MaterialRequisitionx::Engine => '/material_requisition'
  mount BaseMaterialx::Engine => '/base_material'
  mount ExtConstructionProjectx::Engine => '/project'
  mount Kustomerx::Engine => '/customer'
  mount BizWorkflowx::Engine => '/wf'
  mount PettyWarehousex::Engine => '/warehouse'
  mount Supplierx::Engine => '/supplier'
  
  resource :session
  
  root :to => "authentify::sessions#new"
  match '/signin',  :to => 'authentify::sessions#new'
  match '/signout', :to => 'authentify::sessions#destroy'
  match '/user_menus', :to => 'user_menus#index'
  match '/view_handler', :to => 'authentify::application#view_handler'
end
