
repl-start() (
  _repl-init

  if [[ -f $pid_file ]]; then
    echo "*** Already started"
    repl-status
    return
  fi

  lein repl :headless >/dev/null &
  pid=$!
  _repl-wait-for-port-file
  ps -p "$pid" >/dev/null ||
    die echo "Failed to start an nrepl server"
  echo "$pid" > "$pid_file"

  echo "REPL server started on port $(< "$port_file"); pid $(< "$pid_file")"
)

repl-status() (
  _repl-check
  echo "REPL server running on port $(< "$port_file"); pid $(< "$pid_file")"
)

repl-stop() (
  _repl-check
  _repl-kill
  echo "REPL server stopped"
)

repl-connect-lein() (
  _repl-check
  lein repl :connect
)

# shellcheck disable=2009,2062
repl-debug() (
  _repl-init || exit
  repl-status || true
  if $is_macos; then
    (
      set -x
      pid=$(< "$pid_file")
      ps -o pid,ppid,command | grep "${pid}[ ]"
    )
  else
    (
      set -x
      ps -fau | grep '[l]ein'
      pid=$(< "$pid_file")
      ps -p "$pid" --ppid "$pid"
      ps -p "$pid" --ppid "$pid" -o pid=
    )
  fi
)

_repl-init() {
  set -e -u -o pipefail
  shopt -s inherit_errexit &>/dev/null || true

  die() { echo "$*"; exit 1; }

  [[ $OSTYPE == darwin* ]] && is_macos=true || is_macos=false

  port_file=./.nrepl-port
  port_file_home=$HOME/.lein/repl-port
  pid_file=./.nrepl-pid

  rm -f "$port_file_home"

  if [[ -f $port_file && ! -f $pid_file ]]; then
    rm -f "$port_file"
  elif [[ -f $pid_file && ! -f $port_file ]]; then
    _repl-kill
  fi
}

_repl-kill() (
  pid=$(< "$pid_file")
  if $is_macos; then
    read -r -a pids <<<"$(
      # shellcheck disable=2009
      ps -o pid,ppid | grep "[ ]$pid"
    )"
  else
    read -r -a pids <<<"$(
      ps -p "$pid" --ppid "$pid" -o pid= | xargs
    )"
  fi
  set -x
  kill -9 "${pids[@]}"
  rm -f "$port_file" "$pid_file"
)

_repl-check() {
  _repl-init
  [[ -f $port_file ]] || die "REPL not running, no $port_file file"
  [[ -f $pid_file ]] || die "REPL not running, no $pid_file file"
}

_repl-wait-for-port-file() (
  i=0
  while [[ $((i++)) -lt 20 ]] &&
    [[ ! -f $port_file ]] &&
    [[ ! -f $port_file_home ]]
  do
    sleep 0.5
  done

  if [[ ! -f $port_file ]]; then
    [[ -f $port_file_home ]] ||
      die "No $port_file or $port_file_home file"
    mv "$port_file_home" "$port_file"
  fi
)
