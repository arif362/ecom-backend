Predictor.redis = Redis.new(host: ENV['REDIS_HOST'], port: ENV['REDIS_PORT'])

Predictor.processing_technique(:lua)
