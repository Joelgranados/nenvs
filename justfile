reg_name := "registry.json"

clean:
  rm -f {{reg_name}}

create_reg:
  touch {{reg_name}}

top:
  echo "{ \"flakes\": [" >> {{reg_name}}

registries:
  ref=$(git rev-parse HEAD); \
  first_loop="true"; \
  for dir in $(ls); do \
    if [[ -d $dir ]]; then \
      if [[ ! -v first_loop ]]; then \
        echo "," >> {{reg_name}}; \
      fi; \
      cat registry.tmpl \
        | sed "s/NIX_ENV_NAME/$dir/" \
        | sed "s/NIX_ENV_REF/$ref/" \
        >> {{reg_name}}; \
      unset first_loop; \
    fi; \
  done

bottom:
  echo "], \"version\":2 }" >> {{reg_name}}

all: clean top registries bottom
