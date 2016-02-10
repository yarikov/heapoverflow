ThinkingSphinx::Index.define :answer, with: :active_record do
  indexes body
  indexes user.full_name, as: :author, sortable: true

  has user_id, created_at, updated_at
end
