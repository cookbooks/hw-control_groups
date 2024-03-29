def load_current_resource
  node.include_recipe 'control_group::default'
  ControlGroups.rules_struct_init(node)
  new_resource.user new_resource.name unless new_resource.user
end

action :create do

  # check existing
  if(node[:control_groups][:rules][:active][new_resource.user])
    raise "Control Groups Rule already exists for user: #{new_resource.user}"
  end

  # create structure
  struct = {
    :controllers => new_resource.controllers,
    :destination => new_resource.destination
  }

  unless(node[:control_groups][:config] && node[:control_groups][:config][:structure])
    raise "Control groups configuration must be defined!"
  end

  # check for existing destination
  dest = node[:control_groups][:config][:structure][struct[:destination]]
  raise "Invalid destination provided for rule (dest: #{struct[:destination]})" unless dest

  # check for controllers
  struct[:controllers].map(&:to_s).each do |cont|
    unless(dest[cont])
      raise "Invalid controller provided for rule (controller: #{cont})"
    end
  end

  node[:control_groups][:rules][:active][new_resource.user] = struct
end

action :delete do
  # Nothing \o/
end
