require 'puppet/provider'

module_lib = Pathname.new(__FILE__).parent.parent.parent.parent
require File.join module_lib, 'puppet_x/aptly/cli'

Puppet::Type.type(:aptly_publish).provide(:cli) do
  mk_resource_methods

  def create
    Puppet.info("Publishing Aptly #{resource[:source_type]} #{name}")

    flags = {
      'distribution' => resource[:distribution],
      'label'        => resource[:label]
    }

    if resource[:architectures] != :undef
      flags['architectures'] = [resource[:architectures]].join(',')
    end

    Puppet_X::Aptly::Cli.execute(
      uid:       resource[:uid],
      gid:       resource[:gid],
      object:    :publish,
      action:    resource[:source_type],
      arguments: [name, resource[:prefix]],
      flags:     flags
    )
  end

  def destroy
    Puppet.info("Destroying Aptly Publish #{name}")

    Puppet_X::Aptly::Cli.execute(
      uid: resource[:uid],
      gid: resource[:gid],
      object: :publish,
      action: 'drop',
      arguments: [name, resource[:prefix]],
      flags: { 'force-drop' => resource[:force] ? 'true' : 'false' }
    )
  end

  def exists?
    Puppet.debug("Check if #{name} exists")

    Puppet_X::Aptly::Cli.execute(
      uid: resource[:uid],
      gid: resource[:gid],
      object: :publish,
      action: 'list',
      flags: { 'raw' => 'true' }
    ).lines.map(&:chomp).include? "#{resource[:prefix]} #{resource[:distribution]}"
  end
end
