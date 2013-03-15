# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :purchase do
    user_id 1
    coin_package_slug "MyString"
  end
end
