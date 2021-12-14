function dotfish --argument-names cmd --description "Auto-source .fish scripts"
  switch "$cmd"
    case init
      set --local hash (echo -n $PWD | openssl sha256 | cut -d' ' -f2)

      set --local store_path ~/.dotfish
      set --local index_path $store_path/index
      set --local hash_path $store_path/$hash

      mkdir -p $store_path
      touch $index_path

      if not grep --quiet "$hash $PWD" $index_path
        echo "$hash $PWD" >> $index_path
      end

      echo "Dotfish enabled for this folder."
      if not test -e .fish
        echo "function hello" > .fish
        echo "  echo Hello \$argv" >> .fish
        echo "end" >> .fish
        echo
        echo "Added an example .fish script:"
        cat .fish
      end

      cp .fish $hash_path
      
      chmod 700 $store_path
      chmod 600 $index_path
      chmod 600 $hash_path

      _dotfish_update
    
    case diff
      set --local hash (echo -n $PWD | openssl sha256 | cut -d' ' -f2)
      set --local hash_path ~/.dotfish/$hash
      if not test -O $hash_path
        echo ".fish not found" >&2
        return 1
      end
      diff $hash_path .fish

    case load reload
      if test -O .fish
        _dotfish_clear
        _dotfish_load
      else
        echo ".fish not found" >&2
        return 1
      end

    case unload
      _dotfish_clear
    
    case ""
      if not test -O .fish
        echo ".fish not found" >&2
        return 1
      end

      if not set --query __dotfish_loaded
        echo ".fish not loaded" >&2
        return 1
      end

      echo "Variables: "
      for it in $__dotfish_vars; echo "· $it"; end
      echo
      echo "Functions: "
      for it in $__dotfish_functions; echo "· $it"; end
    
    case -h --help '*'
      echo "Usage: dotfish         Show current symbols"
      echo "       dotfish init    Enable current folder for .fish"
      echo "       dotfish load    Reload .fish script (alias: reload)"
      echo "       dotfish unload  Remove loaded symbols"
      echo "       dotfish diff    Show .fish diff"
  end
end

function _dotfish_clear
  set_color 808080
  for it in $__dotfish_vars
    echo "dotfish: -$it (τ)"
    set --erase $it
  end
  set --erase __dotfish_vars

  for it in $__dotfish_functions
    echo "dotfish: -$it (λ)"
    functions --erase $it
  end
  set --erase __dotfish_functions

  set --erase __dotfish_loaded
  set_color normal
end

function _dotfish_load
  set_color 808080 

  set --local hash (echo -n $PWD | openssl sha256 | cut -d' ' -f2)
  set --local hash_path ~/.dotfish/$hash

  if not test -O $hash_path
    echo "dotfish: forbidden for this folder" >&2
    return 1
  end

  if not diff $hash_path .fish &> /dev/null
    echo "dotfish: .fish is changed, run 'dotfish init' to refresh" >&2
    return 1
  end

  set --local prev_vars (set --names --global)
  set --local prev_functions (functions)
  source .fish

  set --local curr_vars (set --names --global)
  set --global __dotfish_vars
  for it in $curr_vars
    if not contains $it $prev_vars
      set --append __dotfish_vars $it
      echo "dotfish: +$it (τ)"
    end
  end

  set --global __dotfish_functions
  for it in (functions)
    if not contains $it $prev_functions
      set --append __dotfish_functions $it
      echo "dotfish: +$it (λ)"
    end
  end

  set --global __dotfish_loaded $PWD
  set_color normal
end

function _dotfish_update --on-variable PWD
  test $PWD != "$__dotfish_loaded"
  and _dotfish_clear
  and test -O .fish
  and _dotfish_load
  return
end

_dotfish_update