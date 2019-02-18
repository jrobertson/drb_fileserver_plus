Gem::Specification.new do |s|
  s.name = 'drb_fileserver_plus'
  s.version = '0.3.1'
  s.summary = 'Designed to provide fault tolerant access to a DRb file ' + 
      'server when 2 or more back-end nodes are running.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/drb_fileserver_plus.rb']
  s.add_runtime_dependency('drb_fileclient', '~> 0.4', '>=0.4.5') 
  s.add_runtime_dependency('sps-pub', '~> 0.5', '>=0.5.5')
  s.signing_key = '../privatekeys/drb_fileserver_plus.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/drb_fileserver_plus'
end
