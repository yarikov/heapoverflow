FactoryGirl.define do
  factory :attachment do
    file { File.open("#{Rails.root}/spec/rails_helper.rb") }

    factory :old_attachment do
      created_at 3.days.ago
    end
  end
end
