################################################################################
#
# Welcome to omnitruck
#
# This is the default recipe. It is the only recipe that runs as root. Here we
# install all the components we need to be functional or have to be done as
# root.
#
################################################################################

# We include chef-sugar because it gives us easy ways to interact with encrypted
# data bags. It may go away in the future.
include_recipe 'chef-sugar::default'

# We use the chef_handler recipe/cookbook so that we can register the an
# exception handler. The only issue here is that we register it inside the
# recipe so we are only going to get converge time exceptions.
include_recipe 'chef_handler::default'

# We include the delivery-truck default recipe so any setup that delivery-truck
# needs gets done.
include_recipe 'delivery-truck::default'

# We include habitat-build default recipe to get habitat installed.
include_recipe 'habitat-build::default'

include_recipe 'fastly::default'

load_delivery_chef_config

# We need aws creds so we get them here.
aws_creds = encrypted_data_bag_item_for_environment('cia-creds', 'chef-cia')

template File.join(node['delivery']['workspace']['root'], 'aws_config') do
  source 'aws_config.erb'
  variables aws_creds: aws_creds
  sensitive true
end

include_recipe 'cia_infra::ruby'

#### LOGGING OUTPUT FOR DEBUGGING PURPOSES
log "aws machine option" do
  message CIAInfra.machine_options(node, 'us-west-2', 1).inspect
end
