#
# Copyright 2012-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Original file from: https://github.com/opscode-cookbooks/rabbitmq/blob/212fa203ff4dd508f19d4cc4d84758330c8af6ab/providers/plugin.rb
# Modified by Pivotal to property parse plugin output from vFabric RabbitMQ.
# A space was added after {name} to prevent misparsing of "supported plugins" added
# by vFabric RabbitMQ
#


def plugins_bin_path(return_array=false)
  path = ENV.fetch('PATH') + ':/usr/lib/rabbitmq/bin'
  return_array ? path.split(':') : path
end

def plugin_enabled?(name)
  cmdStr = "rabbitmq-plugins list -e '#{name}\\b'"
  cmd = Mixlib::ShellOut.new(cmdStr)
  cmd.environment['HOME'] = ENV.fetch('HOME', '/root')
  cmd.environment['PATH'] = plugins_bin_path
  cmd.run_command
  Chef::Log.debug "rabbitmq_plugin_enabled?: #{cmdStr}"
  Chef::Log.debug "rabbitmq_plugin_enabled?: #{cmd.stdout}"
  cmd.error!
  cmd.stdout =~ /\b#{name} \b/
end

action :enable do
  unless plugin_enabled?(new_resource.plugin)
    execute "rabbitmq-plugins enable #{new_resource.plugin}" do
      Chef::Log.info "Enabling RabbitMQ plugin '#{new_resource.plugin}'."
      path plugins_bin_path(true)
      new_resource.updated_by_last_action(true)
    end
  end
end

action :disable do
  if plugin_enabled?(new_resource.plugin)
    execute "rabbitmq-plugins disable #{new_resource.plugin}" do
      Chef::Log.info "Disabling RabbitMQ plugin '#{new_resource.plugin}'."
      path plugins_bin_path(true)
      new_resource.updated_by_last_action(true)
    end
  end
end
