 #!/bin/bash

 rm -f ~/.influxdbv2/configs
 influx setup \
   --username admin \
   --password <%= v 'influxdb.password' %> \
   --org <%= v 'hostname' %> \
   --bucket system \
   --force