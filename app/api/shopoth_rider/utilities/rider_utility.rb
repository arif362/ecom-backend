module Utilities
  module RiderUtility

    def self.common_dashboard_hash
      {
        'balance': {
          'wallet_balance': 0.0,
          'cash_balance': 0.0,
        },
        'home_deliveries': {
          'total_orders': 0,
          'on_hold_orders': 0,
        },
        'express_deliveries': {
          'total_orders': 0,
          'on_hold_orders': 0,
        },
        'return_deliveries': {
          'total_orders': 0,
          'on_hold_orders': 0,
        },
      }
    end
  end
end
