Rails.application.routes.draw do
  get '/clip', to: 'clip#index'
  post '/clip/upload_clip', to: 'clip#upload_clip'
  post '/clip/upload_image', to: 'clip#upload_image'
  post '/clip/upload_text', to: 'clip#upload_text'

  get 'responsive/index'

  get '/keywords/', to: 'key_word#index'
  post '/keywords/check', to: 'key_word#check'

  get 'text/index'

  post 'text/check'

  get 'banner/index'

  post 'banner/upload', to: 'banner#check'

  post 'responsive/upload', to: 'responsive#file_check'

  post 'responsive/textcheck', to: 'responsive#text_check'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'text#index'
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
