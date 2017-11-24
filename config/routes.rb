Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get 'welcome/about'
  get 'welcome/contact'

  match "/400", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
end
