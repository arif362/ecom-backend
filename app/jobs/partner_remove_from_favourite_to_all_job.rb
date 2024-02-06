class PartnerRemoveFromFavouriteToAllJob < ApplicationJob
  queue_as :default

  def perform(store_id)
    FavoriteStore.where(partner_id: store_id).destroy_all
  end
end
