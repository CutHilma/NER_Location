Rails.application.routes.draw do

  # Halaman Login
  get    '/login',  to: 'session#login'
  post   '/login',  to: 'session#do_login'
  get    '/logout', to: 'session#logout'

  # Halaman Dashboard
  root 'instagram_scraper#index' #homepage
  get 'dashboard', to: 'dashboard#show', as: 'dashboard'

  # Halaman User Management
  get 'user/show'
  get 'user/addData'
  post '/user/create' => 'user#create'
  get '/user/delete/:id' => 'user#delete'
  get '/user/editData/:id' => 'user#editData'
  post '/user/edit/:id' => 'user#edit'
  get '/profile', to: 'user#profile'
  post '/profile/update', to: 'user#update_profile'


  # Intagram Scrapper
  # Tambahkan baris ini:
  get 'instagram_scraper/scrape', to: 'instagram_scraper#scrape', as: 'scrape_instagram_scraper_index'

  # Atau tambahkan sekaligus index:
  get 'instagram_scraper', to: 'instagram_scraper#index', as: 'instagram_scraper_index'

  # Halaman Data
  get 'data/show'
  get 'data/addData'
  post '/data/create' => 'data#create'
  get '/data/delete/:id' => 'data#delete'
  get '/data/editData/:id' => 'data#editData'
  post '/data/edit/:id' => 'data#edit'
  get '/data/export_csv', to: 'data#export_csv', as: 'export_csv_data'


  #Halaman Location
  get "location/index"
  get "location/show"
  get 'location/addData'
  post '/location/create' => 'location#create'
  get '/location/delete/:id' => 'location#delete'
  get '/location/editData/:id' => 'location#editData'
  post '/location/edit/:id' => 'location#edit'


  # Halaman Evaluasi NER rules
  get 'ner_evaluation', to: 'ner_evaluation#index'


  #Halaman SVM
  get 'ner/show'
  get 'ner/train', to: 'ner#train'
  get 'ner/predict', to: 'ner#predict'
  get 'ner/show_grafik', to: 'ner#show_grafik', as: 'ner_show_grafik'
  get 'ner/show_data_training', to: 'ner#show_data_training', as: 'ner_show_data_training'
  get 'ner/visualisasi', to: 'ner#visualisasi', as: 'ner_visualisasi'
  get '/ner/export_predictions_csv', to: 'ner#export_predictions_csv', as: 'export_predictions_csv'
  get '/ner/export_predictions_excel', to: 'ner#export_predictions_excel', as: 'export_predictions_excel'


  #Scraping Data Instagram
  get 'instagram_scraper', to: 'instagram_scraper#index'
  post 'instagram_scraper/scrape', to: 'instagram_scraper#scrape'

  # Halaman prehitungan maual svm
  get 'manual_svm/show', to: 'manual_svm#show', as: 'manual_svm_show'
  post 'manual_svm/train', to: 'manual_svm#train', as: :train_manual_svm

  get "/setup_admin", to: proc {
    UserItem.find_or_create_by!(username: "admin") do |u|
      u.password = "admin123"
      u.role = "admin"
    end
    [200, {"Content-Type" => "text/plain"}, ["Admin created successfully"]]
  }

  post 'instagram_scraper/save_label',
    to: 'instagram_scraper#save_label',
    as: 'save_label_instagram_scraper_index'

end
