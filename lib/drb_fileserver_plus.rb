#!/usr/bin/env ruby

# file: drb_fileserver_plus.rb

# description: Designed to provide fault tolerant access to a DRb file server
#              when 2 or more back-end nodes are running.

require 'sps-pub'
require 'drb_fileclient'


class DRbFileServer

  def initialize(nodes, sps: nil, topic: 'file')
    
    @nodes = nodes.map {|x| 'dfs://' + x}
    @failcount = 0
    @sps, @topic = sps, topic
    
  end
  
  def cp(path, path2)
    
    file_op do |f|
      f.cp File.join(@nodes.first, path), File.join(@nodes.first, path2)
    end
    
    if @sps then
      @sps.notice "%s/copy: %s %s" % [@topic, File.join(@nodes.first, path), 
                               File.join(@nodes.first, path2)]
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
    
    if @sps then
      @sps.notice "%s/mkdir: %s" % [@topic, File.join(@nodes.first, path)]    
    end

  end
  
  def mkdir_p(path)

    file_op {|f| f.mkdir_p File.join(@nodes.first, path) }
    
    if @sps then
      @sps.notice "%s/mkdir_p: %s" % [@topic, File.join(@nodes.first, path)]
    end
    
  end
  
  def mv(path, path2)

    file_op do |f|
      f.mv File.join(@nodes.first, path), File.join(@nodes.first, path2)
    end
    
    if @sps then
      @sps.notice "%s/mv: %s %s" % [@topic, File.join(@nodes.first, path), 
                               File.join(@nodes.first, path2)]
    end

  end   
  
  def read(fname)

    file_op {|f| f.read File.join(@nodes.first, fname) }

  end
  
  def rm(fname)

    file_op {|f| f.rm File.join(@nodes.first, fname) }
    
    if @sps then
      @sps.notice "%s/rm: %s" % [@topic, File.join(@nodes.first, fname)]
    end

  end   

  def write(fname, content)

    file_op {|f| f.write File.join(@nodes.first, fname), content }
    
    if @sps then
      @sps.notice("%s/write: %s" % [@topic, File.join(@nodes.first, fname)])
    end
    
  end
  
  def zip(fname, a)

    file_op {|f| f.zip File.join(@nodes.first, fname), a }
    
    if @sps then
      @sps.notice "%s/zip: %s" % [@topic, File.join(@nodes.first, fname)]
    end
    
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
