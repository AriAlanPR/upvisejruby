Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'ns_product' => 'queryhandle#obtain'
  post 'netsuite_to_upvise' => 'queryhandle#push_from_netsuite'
  get 'upvise_products_list' => 'queryhandle#get_listof_upvise_products'
  get 'upvise_single_product' => 'queryhandle#get_single_upvise_product'
  get 'put_uv_contact' => 'queryhandle#insert_contact'
end
