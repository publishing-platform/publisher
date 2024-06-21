Rails.application.routes.draw do
  root to: redirect("/documents")

  resources :documents, only: %i[index new create]

  scope "/documents/:document_id" do
    get "" => "documents#show", as: :document

    get "/edition" => "editions#edit"
    patch "/edition" => "editions#update"
    post "/editions" => "editions#create", as: :create_edition

    delete "/draft" => "editions#destroy_draft", as: :destroy_draft
    get "/delete-draft" => "editions#confirm_delete_draft", as: :confirm_delete_draft

    get "/preview" => "preview#show", as: :preview_document
    post "/preview" => "preview#create"    

    get "/publish" => "publish#confirmation", as: :publish_confirmation
    post "/publish" => "publish#publish"
    get "/published" => "publish#published", as: :published

    get "/generate-path" => "documents#generate_path", as: :generate_path

    post "/submit-for-2i" => "review#submit_for_2i", as: :submit_for_2i
    post "/approve" => "review#approve", as: :approve

    get "/withdraw" => "withdraw#new", as: :withdraw
    post "/withdraw" => "withdraw#create"

    get "/unwithdraw" => "unwithdraw#confirm", as: :unwithdraw
    post "/unwithdraw" => "unwithdraw#unwithdraw"

    get "/remove" => "remove#remove", as: :remove
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
