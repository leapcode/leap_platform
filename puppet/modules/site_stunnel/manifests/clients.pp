#
# example hiera yaml:
#
#   stunnel:
#     clients:
#       ednp_clients:
#         thrips_9002:
#           accept_port: 4001
#           connect: thrips.demo.bitmask.i
#           connect_port: 19002
#       epmd_clients:
#         thrips_4369:
#           accept_port: 4000
#           connect: thrips.demo.bitmask.i
#           connect_port: 14369
#
# In the above example, this resource definition is called twice, with $name
# 'ednp_clients' and 'epmd_clients'
#

define site_stunnel::clients {
  create_resources(site_stunnel::client, $site_stunnel::clients[$name])
}
