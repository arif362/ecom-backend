module PromotionEngine
  module Configuration

    def self.settings
      YAML.safe_load(File.read(Rails.root.join('lib/promotion_engine/configuration.yml')))
    end
  end
end
