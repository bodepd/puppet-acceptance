# Agents certs will remain waiting for signing on master until this step
#
step "PE: Puppet Master Sign all Requested Agent Certs"
hosts.each do |host| 
  # Master auto signs its own cert on startup
  next if host['roles'].include? 'master'
  on master,"puppet cert --sign #{host}" do
    assert_no_match(/Could not call sign/, stdout, "Unable to sign cert for #{host}")
  end
end
