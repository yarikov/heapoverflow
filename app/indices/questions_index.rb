ThinkingSphinx::Index.define :question, with: :active_record do
  indexes title, sortable: true
  indexes body
  indexes user.full_name, as: :author, sortable: true

  has user_id, created_at, updated_at
end
