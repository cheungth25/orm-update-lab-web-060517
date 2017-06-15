require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE students (id INTEGER PRIMARY KEY, name TEXT, grade TEXT)")
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    if self.id == nil
      DB[:conn].execute("INSERT INTO students (name, grade) VALUES ('#{self.name}', '#{self.grade}')")
    else
      update
    end
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.create(name, grade)
    new_student = self.new(name, grade)
    new_student.save
    new_student
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    query = <<-SQL
      SELECT * FROM students WHERE name = ?
        SQL
    self.new_from_db(DB[:conn].execute(query, name)[0])
  end

  def update
    DB[:conn].execute("UPDATE students SET name='#{self.name}', grade='#{self.grade}' WHERE id='#{self.id}'")
  end
end
