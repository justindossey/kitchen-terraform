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

require "kitchen/terraform/command/validate/post_zero_fifteen_zero"
require "kitchen/terraform/command/validate/pre_zero_fifteen_zero"
require "rubygems"

module Kitchen
  module Terraform
    module Command
      # ValidateFactory is the class of objects which build Validate objects.
      class ValidateFactory
        # #build creates a new instance of an Validate object.
        #
        # @param config [Hash] the configuration of the driver.
        # @return [Kitchen::Terraform::Command::Validate::PreZeroFifteenZero,
        #   Kitchen::Terraform::Command::Validate::PostZeroFifteenZero]
        def build(config:)
          if requirement.satisfied_by? version
            return ::Kitchen::Terraform::Command::Validate::PreZeroFifteenZero.new config: config
          end

          ::Kitchen::Terraform::Command::Validate::PostZeroFifteenZero.new config: config
        end

        # #initialize prepares a new instance of the class
        #
        # @param version [Gem::Version] a client version.
        # @return [Kitchen::Terraform::Command::ValidateFactory]
        def initialize(version:)
          self.requirement = ::Gem::Requirement.new "< 0.15.0"
          self.version = version
        end

        private

        attr_accessor :requirement, :version
      end
    end
  end
end
