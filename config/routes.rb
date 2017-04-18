Rails.application.routes.draw do

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

 #poset forward backend
 post "delete/(:id)", to:"backend#db_delete"
 post "destroy", to:"backend#db_destroy"
 post "db_input", to: "backend#db_input"
 post "img_reproduce", to:"backend#img_reproduce"
 post "product_destroy", to:"backend#db_product_destroy"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
