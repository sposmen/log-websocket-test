require 'em-websocket'
require 'mongo'
require 'pg'
require 'mysql'
require 'cql'

include Mongo

@client = MongoClient.new('localhost', 27017)
@db     = @client['log-widgets']
@coll   = @db['xy_coordenates']

@pg = PG::Connection.open(:dbname => 'pruebas', :user=>'postgres', :password=>'pruebas')

@my = Mysql.new('localhost', 'root', 'pruebas', 'pruebas')

@cassandra = Cql::Client.connect(hosts: ['localhost'])
@cassandra.use('pruebas')
@uuid = Cql::TimeUuid::Generator.new
timer_logMongo = File.open('timerMongo.log', 'w')
timer_logPG = File.open('timerPG.log', 'w')
timer_logMy = File.open('timerMySQL.log', 'w')
timer_logCassandra = File.open('timerCassandra.log', 'w')

timer_logFile = File.open('timerFile.log', 'w')
timer_logFileMem = File.open('timerFileMem.log', 'w')

EM.run {
  EM::WebSocket.run(:host => "0.0.0.0", :port => 8080) do |ws|
    
    ws.onopen { |handshake|
      #Here is where we need to check the user information about permissons and somo needed init data.
      puts "WebSocket connection open"

      ws.send "Hello Client, you connected to #{handshake.path}"
    }

    ws.onclose { puts "Connection closed" }

    ws.onmessage { |msg|
      #Mongo
      beginning = Time.now
      @coll.insert({'user_id'=>1, 'msg'=>msg})
      timer_logMongo.seek(0,IO::SEEK_END)
      timer_logMongo.write("#{Time.now - beginning}\n")
      
      #PG
      beginning = Time.now
      @pg.exec('INSERT INTO xy_coordenates(user_id, msg) VALUES ($1,$2)',[1, msg])
      timer_logPG.seek(0,IO::SEEK_END)
      timer_logPG.write("#{Time.now - beginning}\n")
      
      #MySQL
      beginning = Time.now
      st = @my.prepare("INSERT INTO xy_coordenates(user_id, msg) VALUES (?,?)")
      st.execute(1, msg)
      timer_logMy.seek(0,IO::SEEK_END)
      timer_logMy.write("#{Time.now - beginning}\n")
      
      #Cassandra
      beginning = Time.now
      st = @cassandra.prepare("INSERT INTO xy_coordenates(id, user_id, msg) VALUES (?,?,?)")
      st.execute(@uuid.next, 1, msg)
      timer_logCassandra.seek(0,IO::SEEK_END)
      timer_logCassandra.write("#{Time.now - beginning}\n")


      #File
      beginning = Time.now
      File.open('general.log', 'a') { |f|
        f.write('1;' + '"'+msg+'"'+"\n")
      }
      timer_logFile.seek(0,IO::SEEK_END)
      timer_logFile.write("#{Time.now - beginning}\n")
      
      #File in MEM
      beginning = Time.now
      File.open('logmem/general.log', 'a') { |f|
        f.write('1;' + '"'+msg+'"'+"\n")
      }
      timer_logFileMem.seek(0,IO::SEEK_END)
      timer_logFileMem.write("#{Time.now - beginning}\n")
      
    }
  end
}
