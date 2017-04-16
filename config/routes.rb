Rails.application.routes.draw do

  # Add your extension routes here
 # match '/1c_exchange.php' => 'exchange1c#main', via: [:get, :post]
  #match '/test' => 'exchange1c#test', via: [:get, :post]
        get '/test', to: 'exchange1c#test'









end


Spree::Core::Engine.add_routes do
 namespace :admin, path: Spree.admin_path do
     resource :xchange, only: [:edit, :update] do
       post :testload, on: :collection
     end
   end
end
