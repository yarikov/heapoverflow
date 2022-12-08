# frozen_string_literal: true

class Searcher
  MODELS = %w[User Question Answer Comment].freeze

  def self.call(query, class_name, **options)
    return [] if query.blank?

    models = class_name.in?(MODELS) ? Array.wrap(class_name.constantize) : MODELS.map(&:constantize)

    Searchkick.search(query, models: models, **options)
  end
end
