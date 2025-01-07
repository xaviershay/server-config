 #!/bin/bash

 rm -f ~/.influxdbv2/configs
 influx setup \
   --username admin \
   --password <%= v 'influxdb.password' %> \
   --org <%= v 'influxdb.org' %> \
   --bucket system \
   --force