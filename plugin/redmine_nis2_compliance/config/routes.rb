# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  # Project-scoped routes
  resources :projects do
    # NIS2 Dashboard
    get 'nis2', to: 'nis2_dashboard#index', as: 'nis2_dashboard'

    # Gap Analyses
    resources :nis2_gap_analyses, path: 'nis2/gap_analyses' do
      member do
        post 'review'
        get 'export'
      end

      # Control Assessments (nested under gap analyses)
      resources :nis2_assessments, path: 'assessments', only: [:edit, :update] do
        member do
          post 'create_issue'
        end
      end
    end
  end

  # Admin routes (global control management)
  scope '/admin' do
    resources :nis2_controls, except: [:destroy] do
      member do
        post 'deactivate'
      end
    end
  end
end
