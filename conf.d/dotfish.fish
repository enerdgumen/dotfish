function dotfish --argument-names cmd --description "Auto-source .fish scripts"
  switch "$cmd"
    case init
      set --local store_path ~/.dotfish
      set --local salt_path $store_path/salt
      set --local folders_path $store_path/folders

      if not test -O $salt_path
        mkdir -p $store_path
        openssl rand -hex 32 > $salt_path
      end

      set hash (
        echo -n $PWD |
        command cat - $salt_path |
        openssl sha256 |
        cut -d' ' -f2
      )

      touch $folders_path
      if not grep --quiet $hash $folders_path
        echo "$hash $PWD" >> $folders_path
      end

      chmod 700 $store_path
      chmod 600 $salt_path
      chmod 600 $folders_path

      echo "Dotfish enabled for this folder."
      if not test -e .fish
        echo "function hello" > .fish
        echo "  echo Hello \$argv" >> .fish
        echo "end" >> .fish
        echo
        echo "Added an example .fish script:"
        cat .fish
      end
      _dotfish_update
    
    case load reload
      if test -O .fish
        _dotfish_clear
        _dotfish_load
      else
        echo "There is no .fish script in this folder :-("
        return 1
      end

    case unload
      _dotfish_clear
    
    case ""
      if not test -O .fish
        echo "There is no .fish script in this folder :-("
        return 1
      end

      if not set --query __dotfish_loaded
        echo "Dotfish is not enabled for this folder :-("
        return 1
      end

      echo "Variables: "
      for it in $__dotfish_vars; echo "· $it"; end
      echo
      echo "Functions: "
      for it in $__dotfish_functions; echo "· $it"; end
    
    case -h --help '*'
      echo "Usage: dotfish         Show current symbols"
      echo "       dotfish init    Enable the current folder for .fish"
      echo "       dotfish load    Reload the .fish script (alias: reload)"
      echo "       dotfish unload  Remove the loaded symbols"
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
  set --local forbidden_message "dotfish: forbidden for this folder"
  set --local store_path ~/.dotfish
  set --local salt_path $store_path/salt
  set --local folders_path $store_path/folders

  if not test -O $salt_path -a -O $folders_path
    echo $forbidden_message >&2
    return 1
  end

  set hash (
    echo -n $PWD |
    command cat - $salt_path |
    openssl sha256 |
    cut -d' ' -f2
  )

  if not grep --quiet $hash $folders_path
    echo $forbidden_message >&2
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