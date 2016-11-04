module LeapCli
  class Cloud

    #
    # returns the latest official debian image for
    # a particular AWS region
    #
    # https://wiki.debian.org/Cloud/AmazonEC2Image/Jessie
    # current list based on Debian 8.4
    #
    # might return nil if no image is found.
    #
    def self.aws_image(region)
       image_list = %q[
  ap-northeast-1 ami-d7d4c5b9
  ap-northeast-2 ami-9a03caf4
  ap-southeast-1 ami-73974210
  ap-southeast-2 ami-09daf96a
  eu-central-1 ami-ccc021a3
  eu-west-1 ami-e079f893
  sa-east-1 ami-d3ae21bf
  us-east-1 ami-c8bda8a2
  us-west-1 ami-45374b25
  us-west-2 ami-98e114f8
  ]
      region_to_image = Hash[image_list.strip.split("\n").map{|i| i.split(" ")}]
      return region_to_image[region]
    end

  end
end