Log Websocket Test
==================

Configuration
=============
Modify the file `log-websocket.rb` acording to your needs
You need to install `em-websocket`, `mongo`, `pg`, `mysql` gems to ensure it.


Start de Websocket service
==========================

```sh
ruby log-websocket.rb
```


Check the results
=================

According to test type a file is generated as `.log`

```sh
ruby avg.rb timer*
```


This test has as purpose test the average speed between Mongo, Postgres, MySQL and Filesystem as logger 
when a Browser WebSocket is connected througth ruby em-websocket

Not else.
