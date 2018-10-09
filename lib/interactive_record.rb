require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
  def self.table_name
    self.to_s.downcase.pluralize 
  end 

  def self.column_names 
    DB[:conn].results_as_hash = true
     table_columns = DB[:conn].execute("PRAGMA table_info(#{table_name})")
     table_columns.reject{|col| col["name"].nil?}.
      map{|col| col["name"]}
  end

  def initialize(objects_hash={})
    objects_hash.each do |k, v|
      self.send("#{k}=", v)
    end 
  end 

  def save 
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert}(#{col_names_for_insert})
      VALUES (#{values_for_insert})
      SQL
     DB[:conn].execute(sql)
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def table_name_for_insert
    self.class.table_name 
  end 
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end 
  
  
  


end