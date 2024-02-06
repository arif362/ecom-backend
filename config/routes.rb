# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount ShopothWarehouse::Base => '/'
  mount Ecommerce::Base => '/shop'
  mount ShopothRider::Base => '/rider'
  mount ShopothPartner::Base => '/partner'
  mount ShopothCorporateUser::Base => '/corporate'
  mount ShopothCustomerCare::Base => '/customer_care'
  mount Finance::Base => '/finance'
  mount ThirdPartyService::Base => '/3ps'
  mount ThirdPartyService::Thanos::Base => '/3ps/thanos'
  mount ShopothDistributor::Base => '/distributor'

  namespace :api do
    namespace :v1 do
      devise_for :users,
                 path: '',
                 path_names: {
                   sign_in: 'login',
                   registration: 'signup',
                   password: 'secret',
                 },
                 controllers: {
                   sessions: 'sessions',
                   registrations: 'registrations',
                   passwords: 'passwords',
                 }
    end
  end

  direct :rails_public_blob do |blob|
    File.join(ENV['CDN_HOST'], blob.key)
  end
end
