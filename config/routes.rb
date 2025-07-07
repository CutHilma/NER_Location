Rails.application.routes.draw do
  get "instagram_scraper/index"
  get "instagram_scraper/scrape"
  # Halaman Login
  root 'pages#login'  # homepage
  get 'login', to: 'pages#login'
  post 'login', to: 'pages#login'
  get 'pages/logout', to: 'pages#logout'

  # Halaman Dashboard
  get 'dashboard', to: 'dashboard#show'

  # Halaman User Managemen
  get 'user/show'
  get 'user/addData'
  post '/user/create' => 'user#create'
  get '/user/delete/:id' => 'user#delete'
  get '/user/editData/:id' => 'user#editData'
  post '/user/edit/:id' => 'user#edit'

  # Halaman Data
  get 'data/show'
  get 'data/addData'
  post '/data/create' => 'data#create'
  get '/data/delete/:id' => 'data#delete'
  get '/data/editData/:id' => 'data#editData'
  post '/data/edit/:id' => 'data#edit'

  #Halaman SVM
  get 'ner/show'
  get 'ner/train', to: 'ner#train'
  get 'ner/predict', to: 'ner#predict'
  
  #Scraping Data Instagram
  get 'instagram_scraper', to: 'instagram_scraper#index'
  post 'instagram_scraper/scrape', to: 'instagram_scraper#scrape'


end
