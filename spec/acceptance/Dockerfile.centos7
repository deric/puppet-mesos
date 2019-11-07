FROM deric/centos7-puppet:5.5.17

RUN mkdir -p /var/run/sshd && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -q -N "" \
  && ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key -q -N ""

EXPOSE 22
CMD ["/sbin/init"]