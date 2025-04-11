#!/bin/bash
set -e

# Function to create a file with a placeholder header comment
create_file() {
  local file_path="$1"
  echo "# ${file_path}" > "$file_path"
}

# Create directories under the gem root
mkdir -p prpl/lib/prpl/services/search
mkdir -p prpl/lib/prpl/services/inventory
mkdir -p prpl/lib/prpl/services/products
mkdir -p prpl/lib/prpl/pdf/generators
mkdir -p prpl/lib/prpl/pdf/layouts
mkdir -p prpl/lib/prpl/pdf/utils
mkdir -p prpl/lib/prpl/models
mkdir -p prpl/lib/prpl/utils
mkdir -p prpl/spec/services
mkdir -p prpl/spec/pdf
mkdir -p prpl/spec/models
mkdir -p prpl/spec/utils

# Create files under prpl/lib/prpl/services/search/
create_file "prpl/lib/prpl/services/search/base.rb"
create_file "prpl/lib/prpl/services/search/product.rb"
create_file "prpl/lib/prpl/services/search/similarity.rb"
create_file "prpl/lib/prpl/services/search/qr.rb"

# Create files under prpl/lib/prpl/services/inventory/
create_file "prpl/lib/prpl/services/inventory/adjuster.rb"
create_file "prpl/lib/prpl/services/inventory/command.rb"
create_file "prpl/lib/prpl/services/inventory/parser.rb"

# Create files under prpl/lib/prpl/services/products/
create_file "prpl/lib/prpl/services/products/finder.rb"
create_file "prpl/lib/prpl/services/products/filter.rb"
create_file "prpl/lib/prpl/services/products/paginator.rb"

# Create files under prpl/lib/prpl/pdf/generators/
create_file "prpl/lib/prpl/pdf/generators/base.rb"
create_file "prpl/lib/prpl/pdf/generators/single_label.rb"
create_file "prpl/lib/prpl/pdf/generators/roll_label.rb"
create_file "prpl/lib/prpl/pdf/generators/sheet.rb"
create_file "prpl/lib/prpl/pdf/generators/barcode.rb"
create_file "prpl/lib/prpl/pdf/generators/qr_code.rb"

# Create files under prpl/lib/prpl/pdf/layouts/
create_file "prpl/lib/prpl/pdf/layouts/base.rb"
create_file "prpl/lib/prpl/pdf/layouts/grid.rb"
create_file "prpl/lib/prpl/pdf/layouts/single.rb"
create_file "prpl/lib/prpl/pdf/layouts/roll.rb"

# Create files under prpl/lib/prpl/pdf/utils/
create_file "prpl/lib/prpl/pdf/utils/margin_calculator.rb"
create_file "prpl/lib/prpl/pdf/utils/temp_file_handler.rb"
create_file "prpl/lib/prpl/pdf/utils/session_store.rb"

# Create files under prpl/lib/prpl/models/
create_file "prpl/lib/prpl/models/base.rb"
create_file "prpl/lib/prpl/models/product.rb"
create_file "prpl/lib/prpl/models/variant.rb"

# Create files under prpl/lib/prpl/utils/
create_file "prpl/lib/prpl/utils/configuration.rb"
create_file "prpl/lib/prpl/utils/result.rb"
create_file "prpl/lib/prpl/utils/errors.rb"

# Create other root-level files in prpl/lib/prpl/
create_file "prpl/lib/prpl/constants.rb"
create_file "prpl/lib/prpl/version.rb"

# Create main entry point file
create_file "prpl/lib/prpl.rb"

# Create directories and placeholder files in spec/
create_file "prpl/spec/spec_helper.rb"
# You can create additional placeholder files under spec as needed:
mkdir -p prpl/spec/services
mkdir -p prpl/spec/pdf
mkdir -p prpl/spec/models
mkdir -p prpl/spec/utils

# Create gem-level files
create_file "prpl/Gemfile"
create_file "prpl/prpl.gemspec"
create_file "prpl/Rakefile"
create_file "prpl/README.md"

echo "Directory structure created successfully."
