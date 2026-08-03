nodeModules: ''
  trees=$(cd ${nodeModules} && find . -name node_modules -type d -prune -printf '%P\n')

  for tree in $trees; do
    mkdir -p "$tree"
    lndir -silent "${nodeModules}/$tree" "$tree"
  done
''
