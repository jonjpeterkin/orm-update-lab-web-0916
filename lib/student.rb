require_relative "../config/environment.rb"

class Student

	attr_accessor :name, :grade
	attr_reader :id

	def initialize(name, grade, id = nil)
		self.name = name
		self.grade = grade
		@id = id
  end

  def self.create_table
  	sql = <<-SQL
  		CREATE TABLE IF NOT EXISTS students (
  		id INTEGER PRIMARY KEY,
  		name TEXT,
  		grade INTEGER
  		);
  	SQL

  	DB[:conn].execute(sql)
  end

  def self.drop_table
  	sql = "DROP TABLE IF EXISTS students"
  	DB[:conn].execute(sql)
  end

  def self.create(name, grade, id = nil)
  	self.new(name, grade, id).tap(&:save)
  end

  def self.new_from_db(row)
  	self.create(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
  	sql = "SELECT * FROM students WHERE name = ?"
  	self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def save
  	if self.id
  		update
  	else
	  	sql = "INSERT INTO students (name, grade) VALUES (?, ?)"

	  	DB[:conn].execute(sql, self.name, self.grade)
	  	@id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
	  end
  end

  def update
  	sql = <<-SQL
	  	UPDATE students 
	  	SET name = ?, grade = ? 
	  	WHERE id = ?
  	SQL

  	DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
