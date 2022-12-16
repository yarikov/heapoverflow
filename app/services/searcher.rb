# frozen_string_literal: true

class Searcher
  MODELS = %w[Question Answer].freeze

  def self.call(query, class_name, **options)
    models = class_name.in?(MODELS) ? Array.wrap(class_name.constantize) : MODELS.map(&:constantize)

    Searchkick.search(query, models: models, **options)
  end
end
