# == Route Map
#
#                          Prefix Verb   URI Pattern                                                                                       Controller#Action
#  delete_picture_attachment_user DELETE /users/:id/delete_picture_attachment(.:format)                                                    users#delete_picture_attachment
#                           users GET    /users(.:format)                                                                                  users#index
#                                 POST   /users(.:format)                                                                                  users#create
#                        new_user GET    /users/new(.:format)                                                                              users#new
#                       edit_user GET    /users/:id/edit(.:format)                                                                         users#edit
#                            user PATCH  /users/:id(.:format)                                                                              users#update
#                                 PUT    /users/:id(.:format)                                                                              users#update
#                                 DELETE /users/:id(.:format)                                                                              users#destroy
#              rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#        rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                 GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#       rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
# rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                 GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#              rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#       update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#            rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'users#index'

  resources :users, except: %i[show] do
    member do
      delete :delete_picture_attachment
    end
  end
end
