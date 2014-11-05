RequisitionCheckoutx::Engine.routes.draw do
  resources :checkouts 
  
  root :to => 'checkouts#index'

end
