function dotfish_load --on-variable PWD
  set_color 808080
  if set --query __dotfish_loaded
    for it in $__dotfish_vars
      echo "- $it"
      set --erase $it
    end
    set --erase __dotfish_vars

    for it in $__dotfish_functions
      echo "- $it"
      functions --erase $it
    end
    set --erase __dotfish_functions

    set --erase __dotfish_loaded
    functions --erase dotfish
  end

  if test -e .fish
    set --local prev_vars (set --names --global)
    set --local prev_functions (functions)
    source .fish

    set --local curr_vars (set --names --global)
    set --global __dotfish_vars
    for it in $curr_vars
      if not contains $it $prev_vars
        echo "τ $it"
        set --append __dotfish_vars $it
      end
    end

    set --global __dotfish_functions
    for it in (functions)
      if not contains $it $prev_functions
        echo "λ $it"
        set --append __dotfish_functions $it
      end
    end

    function dotfish --description "Show symbols read from .fish"
      echo "Variables: "
      for it in $__dotfish_vars; echo "· $it"; end
      echo
      echo "Functions: "
      for it in $__dotfish_functions; echo "· $it"; end
    end

    set --global __dotfish_loaded 1
  end
  set_color normal
end

dotfish_load