#!/usr/bin/env ruby


require 'time'
require 'json'
require 'pry'
#above not required

require_relative '../epiphany/tokenizer'
require_relative 'exercise_count_analyzer'
require_relative 'weight_lift_analyzer'
require_relative 'reps_count_analyzer'

module Example
  class Tokenizer < Epiphany::Tokenizer

    custom_entity_type_and_analyzer entity_name: :reps_count,
                                    custom_analyzer: RepsCountAnalyzer,
                                    required_entities: [:integer, :exercise_repition_word]

    custom_entity_type_and_analyzer entity_name: :exercise_count,
                                    custom_analyzer: ExerciseCountAnalyzer,
                                    required_entities: [:integer, :body_weight_exercise]

    custom_entity_type_and_analyzer entity_name: :weighted_lift,
                                    custom_analyzer: WeightLiftAnalyzer,
                                    required_entities: [:integer, :metric]

    custom_intent_type_by_callback intent_name: :track_weight_lifts,
                                   required_entities: [:weighted_exercise, :integer, :verb, :noun, :weighted_lift],
                                   optional_entities: [:exercise_count, :reps_count, :metric],
                                   keywords_boost: ["set", "reps", "of", "time"]
  end
end

#debug playground
require_relative '../epiphany/tokenizer_cache'

def time_diff_milli(start, finish)
  "#{((finish - start) * 1000.0).round(2)} ms"
end

# Epiphany::Tokenizer::Cache.clear_phrases_cache

start = Time.now
r = Epiphany::Tokenizer::Cache.fetch_phrase("record 55 pushups") do |phrase|
  Example::Tokenizer.new(phrase).results_hash
end
finish = Time.now
puts "#{r['phrase']} =intent=> #{r['top_scored_intent']} =entities=> #{r['matched_entities']} ==> #{time_diff_milli(start, finish)}"

start = Time.now
r = Epiphany::Tokenizer::Cache.fetch_phrase("10 deadlifts 315 lbs") do |phrase|
  Example::Tokenizer.new(phrase).results_hash
end
finish = Time.now
puts "#{r['phrase']} =intent=> #{r['top_scored_intent']} =entities=> #{r['matched_entities']} ==> #{time_diff_milli(start, finish)}"

start = Time.now
r = Epiphany::Tokenizer::Cache.fetch_phrase("add 15 pullups to back workout") do |phrase|
  Example::Tokenizer.new(phrase).results_hash
end
finish = Time.now
puts "#{r['phrase']} =intent=> #{r['top_scored_intent']} =entities=> #{r['matched_entities']} ==> #{time_diff_milli(start, finish)}"

start = Time.now
r = Epiphany::Tokenizer::Cache.fetch_phrase("bench press 275 lbs 8 times") do |phrase|
  Example::Tokenizer.new(phrase).results_hash
end
finish = Time.now
puts "#{r['phrase']} =intent=> #{r['top_scored_intent']} =entities=> #{r['matched_entities']} ==> #{time_diff_milli(start, finish)}"

start = Time.now
r = Epiphany::Tokenizer::Cache.fetch_phrase("add 50 situps to ab workout") do |phrase|
  Example::Tokenizer.new(phrase).results_hash
end
finish = Time.now
puts "#{r['phrase']} =intent=> #{r['top_scored_intent']} =entities=> #{r['matched_entities']} ==> #{time_diff_milli(start, finish)}"

# start = Time.now
# t1 = Example::Tokenizer.new("add 10 reps of 145 lbs to back workout deadlifts")
# finish = Time.now
# puts "#{t1.phrase} ====> #{t1.top_scored_intent} ====> #{time_diff_milli(start, finish)}"
#
# start = Time.now
# t2 = Example::Tokenizer.new("record 55 pushups")
# finish = Time.now
# puts "#{t2.phrase} ====> #{t2.top_scored_intent} ====> #{time_diff_milli(start, finish)}"
#
# start = Time.now
# t3 = Example::Tokenizer.new("leg day squats 315 4 times")
# finish = Time.now
# puts "#{t3.phrase} ====> #{t3.top_scored_intent} ====> #{time_diff_milli(start, finish)}"
#
# start = Time.now
# t4 = Example::Tokenizer.new("add 12 close grip pullups to back day")
# finish = Time.now
# puts "#{t4.phrase} ====> #{t4.top_scored_intent} ====> #{time_diff_milli(start, finish)}"




# start = Time.now
# t1 = ExampleTokenizer.new("add 10 reps of 145 lbs to back workout deadlifts")
# finish = Time.now
# puts "#{t1.phrase} ====> #{t1.scores_quick_report} ====> #{time_diff_milli(start, finish)}"
#
# start = Time.now
# t2 = ExampleTokenizer.new("record 55 pushups")
# finish = Time.now
# puts "#{t2.phrase} ====> #{t2.scores_quick_report} ====> #{time_diff_milli(start, finish)}"
#
# start = Time.now
# t3 = ExampleTokenizer.new("leg day squats 315 4 times")
# finish = Time.now
# puts "#{t3.phrase} ====> #{t3.scores_quick_report} ====> #{time_diff_milli(start, finish)}"
#
# start = Time.now
# t4 = ExampleTokenizer.new("add 12 close grip pullups to back day")
# finish = Time.now
# puts "#{t4.phrase} ====> #{t4.scores_quick_report} ====> #{time_diff_milli(start, finish)}"

#binding.pry