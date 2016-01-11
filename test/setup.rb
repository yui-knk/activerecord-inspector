require 'active_record'

ActiveRecord::Base.configurations = {'test' => {adapter: 'sqlite3', database: ':memory:'}}
ActiveRecord::Base.establish_connection :test

# models
class User < ActiveRecord::Base
  validates :name,  uniqueness: true
  validates :email, uniqueness: true
end

class Blog < ActiveRecord::Base
end

class Post < ActiveRecord::Base
  validates :title, uniqueness: { scope: :category }
end

class Comment < ActiveRecord::Base
  validates :category, uniqueness: true
end

class Author < ActiveRecord::Base
  validates :email, uniqueness: true
end


# migration
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.string :name
      t.string :email
    end
    add_index :users, :name, unique: true

    create_table(:blogs) do |t|
      t.string :title
    end
    add_index :blogs, :title, unique: true

    create_table(:posts) do |t|
      t.string :title
      t.string :category
    end
    add_index :posts, :title, unique: true

    create_table(:comments) do |t|
      t.string :body
      t.string :category
    end
    add_index :comments, [:body, :category], unique: true

    create_table(:authors) do |t|
      t.string :name
      t.string :email
    end
    add_index :authors, :email, unique: true
  end
end
ActiveRecord::Migration.verbose = false
CreateAllTables.up
