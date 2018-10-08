#!/usr/bin/env ruby

# file: drb_fileserver_plus.rb

# description: Designed to provide fault tolerant access to a DRb file server
#              when 2 or more back-end nodes are running.

require 'sps-pub'
require 'drb_fileclient'


class DRbFileServer
  
  attr_accessor :nodes

  def initialize(nodes, sps: nil, topic: 'file')
    
    @nodes = nodes
    @failcount = 0
    @sps, @topic = sps, topic
    
  end
  
  def cp(path, path2)
       
    node = ''
    
    file_op do |f|
      node = 'dfs://' + @nodes.first      
      f.cp File.join(node, path), File.join(node, path2)
    end
    
    if @sps then
      @sps.notice "%s/copy: %s %s" % [@topic, File.join(node, path), 
                               File.join(node, path2)]
    end

  end    

  def exists?(fname)
        
    file_op do |f| 
      node = 'dfs://' + @nodes.first
      f.exists? File.join(node, fname) 
    end

  end  
  
  def ls(path)
    
    file_op do |f| 
      node = 'dfs://' + @nodes.first
      f.ls File.join(node, path)
    end

  end  
  
  def mkdir(path)

    node = ''
    
    file_op do |f| 
      node = 'dfs://' + @nodes.first
      f.mkdir File.join(node, path)
    end
    
    if @sps then
      @sps.notice "%s/mkdir: %s" % [@topic, File.join(node, path)]    
    end

  end
  
  def mkdir_p(path)

    node = ''    

    file_op do |f|
      node = 'dfs://' + @nodes.first
      f.mkdir_p File.join(node, path)
    end
    
    if @sps then
      @sps.notice "%s/mkdir_p: %s" % [@topic, File.join(node, path)]
    end
    
  end
  
  def mv(path, path2)

    node = ''
    
    file_op do |f|
      node = 'dfs://' + @nodes.first
      f.mv File.join(node, path), File.join(node, path2)
    end
    
    if @sps then
      @sps.notice "%s/mv: %s %s" % [@topic, File.join(node, path), 
                               File.join(node, path2)]
    end

  end   
  
  def read(fname)
    
    file_op do |f|
      node = 'dfs://' + @nodes.first
      f.read File.join(node, fname)
    end

  end
  
  def rm(fname)

    node = ''
    
    file_op do |f|
      node = 'dfs://' + @nodes.first
      f.rm File.join(node, fname)
    end
    
    if @sps then
      @sps.notice "%s/rm: %s" % [@topic, File.join(node, fname)]
    end

  end   

  def write(fname, content)

    node = ''
    
    file_op do |f|
      node = 'dfs://' + @nodes.first
      f.write File.join(node, fname), content
    end
    
    if @sps then
      @sps.notice("%s/write: %s" % [@topic, File.join(node, fname)])
    end
    
  end
  
  def zip(fname, a)
    
    node = ''
    
    file_op do |f|
      node = 'dfs://' + @nodes.first
      f.zip File.join(node, fname), a
    end
    
    if @sps then
      @sps.notice "%s/zip: %s" % [@topic, File.join(node, fname)]
    end
    
  end  
  

  private

  def file_op()

    begin
      r = yield(DfsFile)
      @failcount = 0
      r
    rescue
      raise $! if ($!).inspect =~ /No such file or directory/
      puts 'warning: ' + ($!).inspect
      @nodes.rotate!
      @failcount += 1
      retry unless @failcount > @nodes.length
      raise 'DRbFileServerPlus nodes exhausted2'
    end

  end

end

class DRbFileServerPlus


  def initialize(host: 'localhost', port: '61010', nodes: [], sps_host: nil, 
                 sps_port: '59010', sps_topic: 'file')

    @host, @port, @nodes = host, port, nodes
    
    if sps_host then
      @sps = SPSPub.new(host: sps_host, port: sps_port) 
      @topic = sps_topic
    end

  end

  def start()
    
    DRb.start_service "druby://#{@host}:#{@port}", 
        DRbFileServer.new(@nodes, sps: @sps, topic: @topic)
    DRb.thread.join

  end

end
