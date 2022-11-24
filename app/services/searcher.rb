class Searcher
  MODELS = %w[User Question Answer Comment]

  def self.call(query, class_name, **options)
    return [] unless query.present?

    models = class_name.in?(MODELS) ? Array.wrap(class_name.constantize) : MODELS.map(&:constantize)

    Searchkick.search(query, models: models, **options)
  end
end
