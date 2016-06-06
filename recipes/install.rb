

if [ 'fedora', 'rhel' ].include? node['platform_family'] 
  package 'perl-Sys-Syslog'
  package 'perl-Archive-Tar'
  package 'perl-LWP-Protocol-https'
  package 'perl-Mozilla-CA'
  package 'openssl-devel'

  if platform_family?('rhel')
    include_recipe 'build-essential'
    include_recipe 'cpan::bootstrap'

    [
      'LWP::UserAgent::Determined',
      'Crypt::SSLeay',
      'IO::Socket::SSL',
      'LWP::Protocol::https'
    ].each do |mod|
      Chef::Log.debug("Installing #{mod}")
      cpan_client mod do
        action :install
        install_type 'cpan_module'
        force true
        user 'root'
        group 'root'
      end
    end

  else
    package 'perl-LWP-UserAgent-Determined'
  end
else
  # install packages needed by pulledpork
  package node['pulledpork']['dependencies']
end

ark 'pulledpork' do
  url node['pulledpork']['artifact_url']
  version node['pulledpork']['version']
  has_binaries %w(pulledpork.pl)
end

# fix bad permissions in the tarball
file "/usr/local/pulledpork-#{node['pulledpork']['version']}/pulledpork.pl" do
  mode '0755'
end
