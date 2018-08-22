# Introducing the drb_fileserver_plus gem

## Setting up the nodes

Each node must point to the same file directory e.g. /home/james/www

### Node 1

host: 192.168.4.177

    require 'drb_fileserver'

    DRbFileServer.new(host: '0.0.0.0').start

### Node 2

host: 192.168.4.20

    require 'drb_fileserver'

    DRbFileServer.new(host: '0.0.0.0').start

## Setting up the node server

host: 192.168.4.135

    require 'drb_fileserver_plus'

    DRbFileServerPlus.new(host: '0.0.0.0', nodes: ['192.168.4.177','192.168.4.20']).start

## Reading a file from the client machine

    require 'drb_fileclient'

    DfsFile.read('dfs://192.168.4.135/miniwiki/main.md')


The drb_fileserver_plus gem is designed to provide a fault tolerant DRb file service using multiple nodes (DRb file servers) redundantly.

Notes:

* If a node fails (e.g. 192.168.4.177) then the next node is used (e.g. 192.168.4.20)
* The node server will raise an error exception if all nodes fail
* SSHFS was the underlying file system used in each node
* It was intended each node would have an indepent copy of the file system which would be regularly synchronised (using rsync) with the other nodes.

## Resources

* drb_fileserver_plus https://rubygems.org/gems/drb_fileserver_plus

file server drbfileserverplus drb gem rsync dfs dfsfile
