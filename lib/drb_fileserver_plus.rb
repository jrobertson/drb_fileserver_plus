#!/usr/bin/env ruby

# file: drb_fileserver_plus.rb

# description: Designed to provide fault tolerant access to a DRb file server
#              when 2 or more back-end nodes are running.

require 'drb_fileclient'


class DRbFileServer

  def initialize(nodes)
    @nodes = nodes.map {|x| 'dfs://' + x}
    @failcount = 0
  end
  
  def cp(path, path2)

    file_op do |f|
      f.cp File.join(@nodes.first, path), File.join(@nodes.first, path2)
    end

  end    

  def exists?(fname)

    file_op {|f| f.exists? File.join(@nodes.first, fname) }

  end  
  
  def ls(path)

    file_op {|f| f.ls File.join(@nodes.first, path) }

  end  
  
  def mkdir(path)

    file_op {|f| f.mkdir File.join(@nodes.first, path) }

  end
  
  def mkdir_p(path)

    file_op {|f| f.mkdir_p File.join(@nodes.first, path) }

  end
  
  def mv(path, path2)

    file_op do |f|
      f.mv File.join(@nodes.first, path), File.join(@nodes.first, path2)
    end

  end   
  
  def read(fname)

    file_op {|f| f.read File.join(@nodes.first, fname) }

  end
  
  def rm(fname)

    file_op {|f| f.rm File.join(@nodes.first, fname) }

  end   

  def write(fname, content)

    file_op {|f| f.write File.join(@nodes.first, fname), content }
    
  end
  
  def zip(fname, a)

    file_op {|f| f.zip File.join(@nodes.first, fname), a }
    
  end  
  

  private

  def file_op()

    begin
      r = yield(DfsFile)
      @failcount = 0
      r
    rescue
      puts 'warning: ' + ($!).inspect
      @nodes.rotate!
      @failcount += 1
      retry unless @failcount > @nodes.length
      raise 'DRbFileServerPlus nodes exhausted'
    end

  end

end

class DRbFileServerPlus


  def initialize(host: 'localhost', port: '61010', nodes: [])

    @host, @port, @nodes = host, port, nodes

  end

  def start()
    
    DRb.start_service "druby://#{@host}:#{@port}", DRbFileServer.new(@nodes)
    DRb.thread.join

  end

end
