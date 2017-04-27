Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks' }
  # , skip: ['sessions']
  # as :user do
  #  get 'users/sign_in' => redirect('/users/auth/kakao')
  #  post 'users/sign_in', to: 'devise/sessions#create', as: :user_session
  #  get 'users/sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  # end


 root to:"front#index"
 get "pcindex", to: "front#pcindex"
 get "db_admin", to: "front#db_admin"
 get "db_input", to: "front#db_input"
 get "move/(:id)", to: "front#bridge"
 get "contents/(:section)/(:id)", to:"front#contents_reload"
 get "outlink/(:id)", to:"front#outlink"
 get "shop_product/(:id)", to:"front#shop_product"
 get "develop", to:"front#index"
 get "slide_tag/(:slide)", to:"front#slide_tag"
 get "slide_contents/(:slide)/(:index)/(:page)", to:"front#slide_contents"
 get "section/(:menu)", to: "front#section_load"
 get "item_filter", to:"front#item_filter"

 #poset forward backend
 post "kakao", to:"backend#kakao"
 post "delete/(:id)", to:"backend#db_delete"
 post "destroy", to:"backend#db_destroy"
 post "db_input", to: "backend#db_input"
 post "img_reproduce", to:"backend#img_reproduce"
 post "product_destroy", to:"backend#db_product_destroy"
 post "userlike/(:type)/(:id)", to:"backend#userlike"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
