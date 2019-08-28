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

require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_schemas/systems"

module Kitchen
  module Terraform
    class ConfigAttribute
      # {include:Kitchen::Terraform::ConfigSchemas::Systems}
      #
      # If the +systems+ key is omitted then no tests will be executed.
      module Systems
        ::Kitchen::Terraform::ConfigAttribute.new(
          attribute: :systems,
          default_value: lambda do
            []
          end,
          schema: ::Kitchen::Terraform::ConfigSchemas::Systems,
        ).apply config_attribute: self
      end
    end
  end
end
