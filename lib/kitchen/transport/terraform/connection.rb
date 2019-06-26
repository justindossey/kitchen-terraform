# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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

require "kitchen"
require "kitchen/terraform/configurable"
require "kitchen/terraform/error"
require "pathname"

module Kitchen
  module Transport
    class Terraform < ::Kitchen::Transport::Base
      # Instances of the Connection class are responsible for executing Terraform commands.
      class Connection < ::Kitchen::Transport::Base::Connection
        include ::Kitchen::ShellOut

        # Downloads remote files to local host.
        def download(remotes, local)
          local.mkpath
          remotes.each do |remote|
            copy local: local, remote: remote
          end
        rescue => error
          raise ::Kitchen::Transport::TransportFailed, error.message
        end

        # Execute a command on the remote host.
        #
        # @param command [String] command string to execute.
        # @raise [TransportFailed] if the command does not exit successfully.
        def execute(command)
          run_command(
            "terraform #{command}",
            cwd: options.fetch(:directory),
            environment: environment,
            timeout: options.fetch(:timeout),
          )
        rescue ::Kitchen::ShellOut::ShellCommandFailed => error
          raise ::Kitchen::Transport::TransportFailed, error.message
        rescue ::Kitchen::Error => error
          raise ::Kitchen::Terraform::Error, error.message
        end

        private

        def copy(local:, remote:)
          remote.open do |opened_remote|
            @stream_copier.copy_stream opened_remote, local.join(opened_remote.basename)
          end
        end

        def environment
          { "LC_ALL" => nil, "TF_IN_AUTOMATION" => "true" }.merge(
            options.fetch(:environment) do
              {}
            end
          )
        end

        def initialize(options = {}, &block)
          @stream_copier = ::IO
          super options, &block
        end
      end
    end
  end
end
