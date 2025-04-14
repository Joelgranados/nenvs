reg_name := "registry.json"

_top_reg:
  echo "{ \"flakes\": [" >> {{reg_name}}

_registries:
  #!/usr/bin/env bash
  ref=$(git rev-parse HEAD);
  first_loop="true";
  dirs=`find . -maxdepth 1 -type d \
    ! -name '.' ! -name 'test' ! -name '.git' ! -name 'kernel_base' \
    ! -name 'qemu_base' ! -name 'krc' \
    -printf '%f\n'`;
  for dir in $dirs; do
    if [[ ! -v first_loop ]]; then
      echo "," >> {{reg_name}};
    fi;
    cat registry.tmpl \
      | sed "s/NIX_ENV_NAME/$dir/" \
      | sed "s/NIX_ENV_REF/$ref/"\
        >> {{reg_name}};
    unset first_loop;
  done

_bottom_reg:
  echo "], \"version\":2 }" >> {{reg_name}}

# Remove all generated files
clean:
  rm -f {{reg_name}}

# Create {{reg_name}}
create_reg: clean _top_reg _registries _bottom_reg

# Install {{reg_name}} in {{inst_path}}
install inst_path="~/.config/nix/": create_reg
  mv --backup=numbered {{reg_name}} {{inst_path}}

# Update flake lock on envs that depend on {{input}}
update_nixlock input:
  #!/usr/bin/env bash
  reg_str="{{ input }}.url.*nenvs?dir={{ input }}"
  for file in $(find -type f -name flake.nix -exec grep -l "${reg_str}" {} \;); do
    env_dir="$(dirname $file)"
    cmd="nix flake lock --commit-lock-file --update-input {{ input }} ${env_dir}"
    echo ${cmd}
    eval ${cmd}
  done

