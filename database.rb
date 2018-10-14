require 'pg'

module Database
  Connection = PG.connect :dbname => 'practice', :user => 'aditya', :password => 'r00t'
end


class Event
  include Database

  def create_table
    begin
      con = Database::Connection
      con.exec "DROP TABLE IF EXISTS events"
      con.exec "CREATE TABLE events (
                      id INTEGER PRIMARY KEY,
                      name VARCHAR,
                      venue VARCHAR
                )"
    rescue PG::Error => e
      puts e.message
    ensure
      con.close if con
    end
  end

  def create(**data)
    begin
      con = Database::Connection
      con.prepare "create_event", "INSERT INTO events VALUES ($1, $2, $3)"
      rs = con.exec_prepared("create_event" , [data[:id], data[:name], data[:venue]])
    rescue PG::Error => e
      puts e.message
    ensure
      con.close if con
    end
  end

  def update(**data)
    begin
      con = Database::Connection
      con.prepare "update_event", "update events set name = $2, venue = $3 where id = $1"
      rs = con.exec_prepared("update_event", [ data[:id], data[:name], data[:venue] ])
    rescue PG::Error => e
      puts e.message
    ensure
      con.close if con
    end
  end

  def store
    begin
      con = Database::Connection
      con.exec "INSERT INTO events VALUES (3, 'Briefing siang', 'Gwk')"
      puts 'success'
    rescue PG::Error => e
      puts e.message
    ensure
      con.close if con
    end
  end

  def find(id)
    begin
      con = Database::Connection
      stm =  "SELECT * FROM events WHERE id = $1"
      rs = con.exec_params(stm, [id])
      puts rs.values
    rescue PG::Error => e
      puts e.message
    ensure
      #con.close if con
    end
  end

  def index
    begin
      con = Database::Connection
      rs = con.exec "SELECT * FROM events"

      rs.map do |row|
        puts "%s %s %s" % [ row['id'], row['name'], row['venue'].upcase ]
      end

    rescue PG::error => e
      puts e.message
    ensure
      rs.clear if rs
      con.close if con
    end
  end
end


include Database
con = Database::Connection

e = Event.new
run = true
while run do
  puts "
  1. show records
  2. find record
  3. create new record
  4. update record
  press 'quit' if you want to quit"
  print "select command : "
  input_command = gets
  case input_command
  when /1/
    e.index
  when /2/
    print "choose id u want to read : "
    id = gets
    e.find(id)
  when /3/
    data = {}
    print "id : "
    data[:id] = gets.chomp
    print "name : "
    data[:name] = gets.chomp
    print "venue"
    data[:venue] = gets.chomp
    e.create(data)
  when /4/
    data = {}
    print "choose id u want to update : "
    data[:id] = gets.chomp
    rs = e.find(data[:id])
    unless rs.nil?
      puts "No records with that id"
    else
      print "name : "
      data[:name] = gets.chomp
      print "venue : "
      data[:venue] = gets.chomp
      e.update(data)
    end
  when /quit/, /exit/
    run = false
  end
end
