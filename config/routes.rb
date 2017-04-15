Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  match '/1c_exchange.php' => 'exchange1c#main', via: [:get, :post]
  match '/test' => 'exchange1c#test', via: [:get, :post]

end
