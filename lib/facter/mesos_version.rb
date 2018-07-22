# Fact: mesos_version
#
# Purpose: get current Mesos version
#
# Resolution:
#   Tests for presence of mesos-master, returns nil if not present
#   returns output of `mesos-master --version` and splits on space.
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:mesos_version) do
  setcode do
    if Facter::Util::Resolution.which('mesos-master')
      Facter::Util::Resolution.exec('mesos-master --version 2>&1').split(/ /)[1].strip
    end
  end
end
