class RouteDevice < ApplicationRecord
  audited
  include BCrypt

  ###########################################
  # Associations
  ###########################################
  belongs_to :route, optional: true
  has_many :customer_care_reports, as: :reporter
  has_one :authorization_key, as: :authable, class_name: 'AuthorizationKey'
  has_many :users, as: :registerable, class_name: 'User'
  has_many :customer_acquisitions, as: :registered_by

  ###########################################
  # Validations
  ###########################################
  validates :unique_id, uniqueness: true

  ###########################################
  # Callbacks
  ###########################################
  before_create :generate_unique_id

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def generate_unique_id
    number = (SecureRandom.random_number(9e5)+ 1e5).to_i.to_s
    self.unique_id = number
  end

  def customer_acquisition_reports(params = {})
    acquisition_data = customer_acquisitions.
      where(created_at: start_date(params)..end_date(params)).
      where.not(information_status: :incomplete)
    results = acquisition_data.
      group(:information_status).
      pluck('information_status', 'count(id)', 'sum(amount)')


    stat = {
      total_registrations: 0,
      total_amounts: 0,
      amount_received: acquisition_data.where(is_paid: true).sum(:amount).to_d.round,
      half: {registrations: 0, amounts: 0},
      full: {registrations: 0, amounts: 0},
    }
    results.each do |arr|
      stat[:total_registrations] += arr[1]
      stat[:total_amounts] += arr[2]
      temp = {
        registrations: arr[1],
        amounts: arr[2],
      }
      arr[0] == 'half' ? stat[:half] = temp : stat[:full] = temp
    end
    stat[:total_registrations] = stat[:total_registrations]
    stat[:total_amounts] = stat[:total_amounts].to_d.round
    stat[:half][:amounts] = stat[:half][:amounts].to_d.round
    stat[:full][:amounts] = stat[:full][:amounts].to_d.round
    stat
  end

  private
  def start_date(params={})
    month = params[:month]
    year = params[:year]
    start_date = if month.present? && year.present?
                   DateTime.civil(year, month, 1).in_time_zone('Dhaka')
                 else
                   DateTime.now.beginning_of_month
                 end
    start_date.beginning_of_day
  end

  def end_date(params={})
    month = params[:month]
    year = params[:year]
    end_date = if month.present? && year.present?
                 DateTime.civil(year, month, -1).in_time_zone('Dhaka')
               else
                 DateTime.now.end_of_month
               end
    end_date.end_of_day
  end
end
