module ShopothWarehouse
  module V1
    class NewsLetters < ShopothWarehouse::Base

      resource :news_letters do

        # INDEX *************************************************
        desc 'Get all NewsLetters.'
        get do
          news_letters = NewsLetter.where(is_active: true)
          present news_letters, with: ShopothWarehouse::V1::Entities::NewsLetters
        end

        desc 'Get a specific newsLetters details.'
        get '/:id' do
          news_letter = NewsLetter.find_by(id: params[:id])
          unless news_letter
            error!(respond_with_json('Unable to find newsLetter.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          present news_letter, with: ShopothWarehouse::V1::Entities::NewsLetters
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to show details of newsLetter due to: #{error.message}"
          error!(respond_with_json('Unable to show details of newsLetter.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Create a newsLetter.'
        post do
          NewsLetter.create!(email: params[:email])

          respond_with_json('Successfully joined to newsLetter.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to create newsLetter due to: #{error.message}"
          error!(respond_with_json('Unable to create newsLetter.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Update a specific newsLetters details.'
        put '/:id' do
          news_letter = NewsLetter.find_by(id: params[:id])
          unless news_letter
            error!(respond_with_json('Unable to find newsLetter.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          email = params[:email].present? ? params[:email] : news_letter.email
          is_active = params[:is_active].present? ? params[:is_active] : news_letter.is_active
          news_letter.update!(email: email, is_active: is_active)

          respond_with_json("Successfully updated newsLetter's information.", HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to updated newsLetter's information due to: #{error.message}"
          error!(respond_with_json("Unable to updated newsLetter's information.",
                                   HTTP_CODE[:UNPROCESSABLE_ENTITY]), HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end

        desc 'Delete a specific newsLetter.'
        delete do
          news_letter = NewsLetter.find_by(email: params[:email])
          unless news_letter
            error!(respond_with_json('Unable to find newsLetter.', HTTP_CODE[:NOT_FOUND]),
                   HTTP_CODE[:NOT_FOUND])
          end

          news_letter.destroy!
          respond_with_json('Successfully deleted newsLetter.', HTTP_CODE[:OK])
        rescue StandardError => error
          Rails.logger.error "\n#{__FILE__}\nUnable to delete newsLetter due to: #{error.message}"
          error!(respond_with_json('Unable to delete newsLetter.', HTTP_CODE[:UNPROCESSABLE_ENTITY]),
                 HTTP_CODE[:UNPROCESSABLE_ENTITY])
        end
      end
    end
  end
end
