##
## common.rb -- evaluated (last) for every node.
##
## Because common.rb is evaluated last, it is good practice to only modify
## values here if they are empty. This gives a chance for tags and services
## to set values.
##

#
# X509 server certificates that use our own CA
#

if self['x509.use']
  if self['x509.cert'].nil?
    self.set('x509.cert', lambda{file(
      :node_x509_cert,
      :missing => "x509 certificate for node $node. Run `leap cert update` to generate it."
    )})
  end
  if self['x509.key'].nil?
    self.set('x509.key', lambda{file(
     :node_x509_key,
      :missing => "x509 key for node $node. Run `leap cert update` to generate it."
    )})
  end
else
  self.set('x509.cert', nil)
  self.set('x509.key', nil)
end

#
# X509 server certificates that use an external CA
#

if self['x509.use_commercial']
  domain = self['webapp.domain'] || self['domain.full_suffix']
  if self['x509.commercial_cert'].nil?
    self.set('x509.commercial_cert', lambda{file(
      [:commercial_cert, domain],
      :missing => "commercial x509 certificate for node `$node`. " +
        "Add file $file, or run `leap cert csr %s`." % domain
    )})
  end
  if self['x509.commercial_key'].nil?
    self.set('x509.commercial_key', lambda{file(
      [:commercial_key, domain],
      :missing => "commercial x509 key for node `$node`. " +
        "Add file $file, or run `leap cert csr %s`" % domain
    )})
  end

  #
  # the content of x509.commercial_cert might include the cert
  # and the full CA chain, or it might just be the cert only.
  #
  # if it is the cert only, then we want to additionally specify
  # 'commercial_ca_cert'. Otherwise, we leave this empty.
  #
  if self['x509.commercial_ca_cert'].nil?
    self.set('x509.commercial_ca_cert', lambda{
      if self['x509.commercial_cert'].scan(/BEGIN CERTIFICATE/).length == 1
        try_file(:commercial_ca_cert)
      else
        nil
      end
    })
  end
else
  self.set('x509.commercial_cert', nil)
  self.set('x509.commercial_key', nil)
  self.set('x509.commercial_ca_cert', nil)
end
