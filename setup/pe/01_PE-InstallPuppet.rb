# Pre Test Setup stage
# SCP installer to host, Untar Installer
#
version  = config['pe_ver']
test_name "Install Puppet #{version}"
hosts.each do |host|
  platform = host['platform']
  host['dist'] = "puppet-enterprise-#{version}-#{platform}"

  # determine the distro tar name
  unless File.file? "/opt/enterprise/dists/#{host['dist']}.tar"
    Log.error "PE #{host['dist']}.tar not found, help!"
    Log.error ""
    Log.error "Make sure your configuration file uses the PE version string:"
    Log.error "  eg: rhel-5-x86_64  centos-5-x86_64"
    fail_test "Sorry, PE #{host['dist']}.tar file not found."
  end

  step "Pre Test Setup -- SCP install package to hosts"
  scp_to host, "/opt/enterprise/dists/#{host['dist']}.tar", "/tmp"
  step "Pre Test Setup -- Untar install package on hosts"
  on host,"cd /tmp && tar xf #{host['dist']}.tar"
end

# Install Master first -- allows for auto cert signing
hosts.each do |host|
  next if !( host['roles'].include? 'master' )
  step "SCP Master Answer file to #{host} #{host['dist']}"
  scp_to host, "tmp/answers.#{host}", "/tmp/#{host['dist']}"
  step "Install Puppet Master"
  on host,"cd /tmp/#{host['dist']} && ./puppet-enterprise-installer -a answers.#{host}"
  # TODO: remove this line. It is masking a problem that needs to be resolved
  on host, 'chown -Rvf pe-puppet:pe-puppet /var/opt/lib/pe-puppet/reports'
end

# Install Puppet Agents
step "Install Puppet Agent"
hosts.each do |host|
  next if host['roles'].include? 'master'
  role_agent=FALSE
  role_dashboard=FALSE
  role_agent=TRUE     if host['roles'].include? 'agent'
  role_dashboard=TRUE if host['roles'].include? 'dashboard'

  step "SCP Answer file to dist tar dir"
  scp_to host, "tmp/answers.#{host}", "/tmp/#{host['dist']}"
  step "Install Puppet Agent"
  on host,"cd /tmp/#{host['dist']} && ./puppet-enterprise-installer -a answers.#{host}"
end
