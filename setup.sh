#!/bin/bash
set -e

# Function to create a file with a placeholder header comment
create_file() {
  local file_path="$1"
  echo "# ${file_path}" > "$file_path"
}

# Create directories under the gem root
mkdir -p propel/lib/propel/services/search
mkdir -p propel/lib/propel/services/inventory
mkdir -p propel/lib/propel/services/products
mkdir -p propel/lib/propel/pdf/generators
mkdir -p propel/lib/propel/pdf/layouts
mkdir -p propel/lib/propel/pdf/utils
mkdir -p propel/lib/propel/models
mkdir -p propel/lib/propel/utils
mkdir -p propel/spec/services
mkdir -p propel/spec/pdf
mkdir -p propel/spec/models
mkdir -p propel/spec/utils

# Create files under propel/lib/propel/services/search/
create_file "propel/lib/propel/services/search/base.rb"
create_file "propel/lib/propel/services/search/product.rb"
create_file "propel/lib/propel/services/search/similarity.rb"
create_file "propel/lib/propel/services/search/qr.rb"

# Create files under propel/lib/propel/services/inventory/
create_file "propel/lib/propel/services/inventory/adjuster.rb"
create_file "propel/lib/propel/services/inventory/command.rb"
create_file "propel/lib/propel/services/inventory/parser.rb"

# Create files under propel/lib/propel/services/products/
create_file "propel/lib/propel/services/products/finder.rb"
create_file "propel/lib/propel/services/products/filter.rb"
create_file "propel/lib/propel/services/products/paginator.rb"

# Create files under propel/lib/propel/pdf/generators/
create_file "propel/lib/propel/pdf/generators/base.rb"
create_file "propel/lib/propel/pdf/generators/single_label.rb"
create_file "propel/lib/propel/pdf/generators/roll_label.rb"
create_file "propel/lib/propel/pdf/generators/sheet.rb"
create_file "propel/lib/propel/pdf/generators/barcode.rb"
create_file "propel/lib/propel/pdf/generators/qr_code.rb"

# Create files under propel/lib/propel/pdf/layouts/
create_file "propel/lib/propel/pdf/layouts/base.rb"
create_file "propel/lib/propel/pdf/layouts/grid.rb"
create_file "propel/lib/propel/pdf/layouts/single.rb"
create_file "propel/lib/propel/pdf/layouts/roll.rb"

# Create files under propel/lib/propel/pdf/utils/
create_file "propel/lib/propel/pdf/utils/margin_calculator.rb"
create_file "propel/lib/propel/pdf/utils/temp_file_handler.rb"
create_file "propel/lib/propel/pdf/utils/session_store.rb"

# Create files under propel/lib/propel/models/
create_file "propel/lib/propel/models/base.rb"
create_file "propel/lib/propel/models/product.rb"
create_file "propel/lib/propel/models/variant.rb"

# Create files under propel/lib/propel/utils/
create_file "propel/lib/propel/utils/configuration.rb"
create_file "propel/lib/propel/utils/result.rb"
create_file "propel/lib/propel/utils/errors.rb"

# Create other root-level files in propel/lib/propel/
create_file "propel/lib/propel/constants.rb"
create_file "propel/lib/propel/version.rb"

# Create main entry point file
create_file "propel/lib/propel.rb"

# Create directories and placeholder files in spec/
create_file "propel/spec/spec_helper.rb"
# You can create additional placeholder files under spec as needed:
mkdir -p propel/spec/services
mkdir -p propel/spec/pdf
mkdir -p propel/spec/models
mkdir -p propel/spec/utils

# Create gem-level files
create_file "propel/Gemfile"
create_file "propel/propel.gemspec"
create_file "propel/Rakefile"
create_file "propel/README.md"

echo "Directory structure created successfully."
