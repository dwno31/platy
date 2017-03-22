Rails.application.routes.draw do

 root to:"front#index"
 get "pcindex", to: "front#pcindex"
 get "db_admin", to: "front#db_admin"
 get "db_input", to: "front#db_input"


 #poset forward backend
 post "delete/(:id)", to:"backend#db_delete"
 post "destroy", to:"backend#db_destroy"
 post "db_input", to: "backend#db_input"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
