# encoding: utf-8
#
# A class for the cloud.json file
#
# Example format:
#
# {
#   "my_aws": {
#     "api": "aws",
#     "vendor": "aws",
#     "auth": {
#       "region": "us-west-2",
#       "aws_access_key_id": "xxxxxxxxxxxxxxx",
#       "aws_secret_access_key": "xxxxxxxxxxxxxxxxxxxxxxxxxx"
#     },
#     "default_image": "ami-98e114f8",
#     "default_options": {
#       "InstanceType": "t2.nano"
#     }
#   }
# }
#

module LeapCli; module Config

  # http://fog.io/about/supported_services.html
  VM_APIS = {
    'aws' => 'fog-aws',
    'google' => 'fog-google',
    'libvirt' => 'fog-libvirt',
    'openstack' => 'fog-openstack',
    'rackspace' => 'fog-rackspace'
  }

  class Cloud < Hash
    def initialize(env=nil)
    end

    #
    # returns hash, each key is the name of an API that is
    # needed and the value is the name of the gem.
    #
    # only provider APIs that are required because they are present
    # in cloud.json are included.
    #
    def required_gems
      required = {}
      self.each do |name, conf|
        api = conf["api"]
        required_gems[api] = VM_APIS[api]
      end
      return required
    end

    #
    # returns an array of all possible providers
    #
    def possible_apis
      VM_APIS.keys
    end

  end

end; end
