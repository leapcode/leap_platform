class passenger::apache{
    case $operatingsystem {
        centos: { include passenger::apache::centos }
        debian: { include passenger::apache::debian }
        defaults: { include passenger::apache::base }
    }
}
