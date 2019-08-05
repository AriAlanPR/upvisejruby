Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'products' => 'queryhandle#obtain'
  get 'netsuite_to_upvise' => 'queryhandle#push_from_netsuite'
  get 'upvise_products' => 'queryhandle#get_upvise_products'
  get 'put_uv_contact' => 'queryhandle#insert_contact'
end
