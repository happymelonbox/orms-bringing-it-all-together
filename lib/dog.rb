require 'pry'
class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id:nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, breed TEXT);")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES (?,?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        self
    end

    def self.create(hash_of_attr)
        new_dog = self.new(hash_of_attr)
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        hash = {
            :id => row[0],
            :name => row[1],
            :breed => row[2]
        }
        self.new(hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL
        found = DB[:conn].execute(sql, name, breed).first
        found ? new_dog = self.new_from_db(found) : new_dog = self.create({name: name, breed: breed})
        new_dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = <<-SQL
        UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
