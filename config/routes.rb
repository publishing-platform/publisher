Rails.application.routes.draw do
  root to: redirect("/documents")

  resources :documents, only: %i[index new create]

  scope "/documents/:document_id" do
    get "" => "documents#show", as: :document
    get "/edition" => "editions#edit"

    get "/publish" => "publish#confirmation", as: :publish_confirmation
    post "/publish" => "publish#publish"
    get "/published" => "publish#published", as: :published
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
