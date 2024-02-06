module ShopothWarehouse::V1::Helpers
  module Constants
    HTTP_CODE = {
      OK: 200,
      CREATED: 201,
      NO_CONTENT: 204,
      BAD_REQUEST: 400,
      UNAUTHORIZED: 401,
      PAYMENT_REQUIRED: 402,
      FORBIDDEN: 403,
      NOT_FOUND: 404,
      METHOD_NOT_ALLOWED: 405,
      NOT_ACCEPTABLE: 406,
      REQUEST_TIMEOUT: 408,
      UNSUPPORTED_MEDIA_TYPE: 415,
      UNPROCESSABLE_ENTITY: 422,
      INTERNAL_SERVER_ERROR: 500,
    }.freeze

    SR_MARGIN_PAYMENT_STATUS = {
      PENDING: 'pending',
      PAID_TO_SR: 'paid_to_sr',
      RECEIVED_BY_SR: 'received_by_sr',
    }.freeze
  end
end

