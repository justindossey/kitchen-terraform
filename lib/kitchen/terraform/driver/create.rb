# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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
require "kitchen/terraform/command/init_factory"
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/command_executor"
require "kitchen/terraform/verify_version"
require "rubygems"

module Kitchen
  module Terraform
    module Driver
      # A Test Kitchen instance is created through the following steps.
      #
      # ===== Initializing the Terraform Working Directory
      #
      # ====== Terraform >= 0.15.0
      #
      # {include:Kitchen::Terraform::Command::Init::PostZeroFifteenZero}
      #
      # ====== Terraform < 0.15.0
      #
      # {include:Kitchen::Terraform::Command::Init::PreZeroFifteenZero}
      #
      # ===== Creating or Selecting the Test Terraform Workspace
      #
      # {include:Kitchen::Terraform::Command::WorkspaceNew}
      #
      # {include:Kitchen::Terraform::Command::WorkspaceSelect}
      class Create
        # #call executes the action.
        #
        # @raise [Kitchen::TransientFailure] if a command fails.
        # @return [self]
        def call
          read_client_version
          verify_version.call version: client_version
          initialize_directory
          create_or_select_workspace

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @option config [String] :client the pathname of the Terraform client.
        # @return [Kitchen::Terraform::Driver::Create]
        def initialize(config:, logger:, version_requirement:, workspace_name:)
          self.complete_config = config.to_hash.merge upgrade_during_init: true, workspace_name: workspace_name
          self.client_version = ::Gem::Version.new "0.0.0"
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: complete_config.fetch(:client),
            logger: logger,
          )
          self.logger = logger
          self.options = {
            cwd: complete_config.fetch(:root_module_directory),
            timeout: complete_config.fetch(:command_timeout),
          }
          self.workspace_name = workspace_name
          self.workspace_new = ::Kitchen::Terraform::Command::WorkspaceNew.new config: complete_config
          self.workspace_select = ::Kitchen::Terraform::Command::WorkspaceSelect.new config: complete_config
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new(
            config: complete_config,
            logger: logger,
            version_requirement: version_requirement,
          )
          self.version = ::Kitchen::Terraform::Command::Version.new
        end

        private

        attr_accessor(
          :client_version,
          :command_executor,
          :complete_config,
          :logger,
          :options,
          :verify_version,
          :version,
          :workspace_name,
          :workspace_new,
          :workspace_select,
        )

        def create_or_select_workspace
          logger.warn "Creating the #{workspace_name} Terraform workspace..."
          command_executor.run command: workspace_new, options: options do |standard_output:|
          end
          logger.warn "Finished creating the #{workspace_name} Terraform workspace."
        rescue ::Kitchen::TransientFailure
          select_workspace
        end

        def initialize_directory
          logger.warn "Initializing the Terraform working directory..."
          command_executor.run(
            command: ::Kitchen::Terraform::Command::InitFactory.new(version: client_version)
              .build(config: complete_config),
            options: options,
          ) do |standard_output:|
          end
          logger.warn "Finished initializing the Terraform working directory."
        end

        def read_client_version
          logger.warn "Reading the Terraform client version..."
          command_executor.run command: version, options: options do |standard_output:|
            self.client_version = ::Gem::Version.new standard_output.slice /Terraform v(\d+\.\d+\.\d+)/, 1
          end
          logger.warn "Finished reading the Terraform client version."
        end

        def select_workspace
          logger.warn "Selecting the #{workspace_name} Terraform workspace..."
          command_executor.run command: workspace_select, options: options do |standard_output:|
          end
          logger.warn "Finished selecting the #{workspace_name} Terraform workspace."
        end
      end
    end
  end
end
