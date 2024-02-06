namespace :recommendations do
  desc 'This task recalculates recommendations'
  task recalculate: :environment do |t, args|
    RecommendationEngine::LearnNewData.new(true).call # delete all
    RecommendationEngine::ProcessMatrixRecalc.new(true).call # process all!!
  rescue => ex
    puts "--- Error recalculating recommendations: #{ex}"
  end
end
