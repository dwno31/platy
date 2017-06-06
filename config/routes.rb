Rails.application.routes.draw do

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks' }, skip: ['new_user_session']
  as :user do
   get 'users/sign_in' => redirect('/users/auth/kakao')
  end


 root to:"front#index"
 get "pcindex", to: "front#pcindex"
 get "db_admin", to: "front#db_admin"
 get "db_input", to: "front#db_input"
 get "move/(:id)", to: "front#bridge"
 get "contents/(:section)/(:id)", to:"front#contents_reload"
 get "outlink/(:id)", to:"front#outlink"
 get "shop_product/(:id)", to:"front#shop_product"
 get "develop", to:"front#index"
 get "insp", to:"front#index"
 get "slide_tag/(:slide)", to:"front#slide_tag"
 get "slide_contents/(:slide)/(:index)/(:page)", to:"front#slide_contents"
 get "section/(:menu)", to: "front#section_load"
 get "item_filter", to:"front#item_filter"
 get "search_toggle", to:"front#search_toggle"
 get "search_item", to:"front#search_item"
 get "search_shop", to:"front#search_shop"
 get "product_rcmd/(:id)", to:"front#product_rcmd"

 #poset forward backend
 post "feedback", to:"backend#feedback"
 post "userimage", to:"backend#userimage"
 post "userprefer", to:"backend#userprefer"
 post "kakao", to:"backend#kakao"
 post "delete/(:id)", to:"backend#db_delete"
 post "destroy", to:"backend#db_destroy"
 post "db_input", to: "backend#db_input"
 post "img_reproduce", to:"backend#img_reproduce"
 post "product_destroy", to:"backend#db_product_destroy"
 post "userlike/(:type)/(:id)", to:"backend#userlike"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
