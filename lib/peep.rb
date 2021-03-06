require 'pg'

class Peep
  attr_reader :id, :text, :username, :time

  def initialize(id, text, username, time)
    @id = id
    @text = text
    @username = username
    @time = time
  end

  def ==(other)
   @id = other.id
  end

  def self.setup_db
    if ENV['ENVIRONMENT'] == 'test'
      PG.connect(dbname: 'chitter_app_test')
    else
      PG.connect(dbname: 'chitter_app')
    end
  end

  def self.all
    connection = setup_db

    result = connection.exec("SELECT * FROM peeps")
    unordered_list = result.map { |peep| Peep.new(peep['id'], peep['text'], peep['username'], peep['time']) }
    order_list = unordered_list.reverse
  end

  def self.create(options)
    connection = setup_db

    return false unless exceed_character_length?(options[:text])
    result = connection.exec("INSERT INTO peeps (text, username, time) VALUES('#{options[:text]}', '#{options[:username]}', '#{Time.new.strftime('%I:%M %p on %A, %B %C %Y')}') RETURNING id, text, time, username")
    Peep.new(result.first['id'], result.first['text'], result.first['username'], result.first['time'])
  end

  def self.delete(peep_id)
    connection = setup_db

    connection.exec("DELETE FROM peeps WHERE id = ('#{peep_id}')")
  end

  def self.edit(options)
    connection = setup_db

    connection.exec("UPDATE peeps SET text=('#{options[:text]}') WHERE id=('#{options[:id]}')")
  end

  def self.find(peep_id)
    connection = setup_db

    result = connection.exec("SELECT * FROM peeps WHERE id = #{peep_id}")
    Peep.new(result.first['id'], result.first['text'], result.first['username'], result.first['time'])
  end


  def self.exceed_character_length?(text)
    text.length <= 280
  end
end
