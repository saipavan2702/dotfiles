# CPOS Templates

`template.cpp` is the active C++ template for CPOS. CPOS discovers this
standard filename automatically, so the local config does not need to contain
an absolute template path.

`cpos-defaults/` is a snapshot of CPOS's built-in starter templates from the
GitHub source. CPOS keeps these defaults embedded in Rust source, not as
standalone template files.

After Stow links it, the live path is:

`~/Library/Application Support/cpos/templates/template.cpp`
