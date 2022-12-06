require 'faker'

def generate_paragraphs(number: rand(2..5))
  number.times.collect { Faker::Lorem.paragraph(sentence_count: rand(5..30)) }.join("\n\n")
end

users = 30.times.collect do
  User.create(
    full_name: Faker::Name.name,
    email: Faker::Internet.email,
    password: 'password'
  )
end

100.times do
  question = Question.create(
    user: users.sample,
    title: Faker::Lorem.question,
    body: generate_paragraphs,
    tag_list: Faker::Lorem.words(number: rand(1..3)).join(', ')
  )

  rand(0..3).times do
    Comment.create(
      commentable: question,
      user: users.sample,
      body: Faker::Lorem.paragraph
    )
  end

  answers = rand(0..3).times.collect do
    answer = Answer.create(
      user: users.sample,
      body: generate_paragraphs(number: rand(1..3)),
      question: question
    )

    rand(0..3).times do
      Comment.create(
        commentable: answer,
        user: users.sample,
        body: Faker::Lorem.paragraph
      )
    end

    answer
  end

  answers.sample&.best!
end
