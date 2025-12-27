step() {
  local message="$1"; shift
  echo -ne "[\e[36m....\e[0m] ${message}"
  if output=$("$@" 2>&1); then
    local last_line=${output##*$'\n'}
    [[ -z $last_line ]] && last_line=' '
    echo -e "\r[ \e[32mOK\e[0m ] ${message} : \e[36m${last_line}\e[0m"
  else
    echo -ne "\r[\e[31mFAIL\e[0m] ${message}"
    echo "${output}"
    exit 1
  fi
}

step_nocap() {
  local message="$1"; shift
  echo -ne "[\e[36m....\e[0m] ${message}"
  if "$@"; then
    echo -e "\r[ \e[32mOK\e[0m ] ${message}"
  else
    echo -e "\r[\e[31mFAIL\e[0m] ${message}"
    exit 1
  fi
}
