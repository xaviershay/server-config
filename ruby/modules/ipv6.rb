class Styx
  # File has a secret in it, hence restrictive permissions
  sftp_task 'ipv6', '/etc/sysctl.conf', 600
  sftp_task 'ipv6: NetworkManager', [
    '/etc/NetworkManager/system-connections/eth0.nmconnection',
    '/etc/NetworkManager/NetworkManager.conf'
  ], 600
end