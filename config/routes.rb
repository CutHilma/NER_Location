Rails.application.routes.draw do
  # Halaman Login
  root 'pages#login'  # homepage
  get 'login', to: 'pages#login'
  post 'login', to: 'pages#login'
 
  # Halaman Dashboard
  get 'dashboard', to: 'dashboard#show'

  # Halaman User Managemen
  get 'user/show'
  get 'user/addData'

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
  
  

end
