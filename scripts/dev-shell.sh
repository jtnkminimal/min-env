#!/usr/bin/env bash
# Task pane for `min run dev`. Shows an interactive task selector with
# arrow-key navigation and runs the selected `min run <task>` command.

set -u

R="" ; D="" ; B=""
CY="" ; PK="" ; GY="" ; GR="" ; YW=""

if [ -t 1 ]; then
  R=$'\e[0m'    ; D=$'\e[2m'    ; B=$'\e[1m'
  CY=$'\e[38;5;87m'              # cyan      — brand
  PK=$'\e[38;5;213m'             # pink      — section headers
  GY=$'\e[38;5;245m'             # grey      — chrome
  GR=$'\e[38;5;120m'             # green     — accent
  YW=$'\e[38;5;220m'             # yellow    — selected row
fi

TASK_FILE=${TASK_FILE:-minimal.toml}
selected=0
status=""

task_description() {
  case "$1" in
    dev) printf "this zellij session" ;;
    claude) printf "Claude Code, standalone" ;;
    shell) printf "plain interactive shell" ;;
    *) printf "project task" ;;
  esac
}

load_tasks() {
  if [ ! -f "$TASK_FILE" ]; then
    printf '%s\n' shell
    return
  fi

  awk '
    /^\[tasks\.[^]]+\]$/ {
      task = $0
      sub(/^\[tasks\./, "", task)
      sub(/\]$/, "", task)
      print task
    }
  ' "$TASK_FILE"
}

tasks=()
while IFS= read -r task; do
  tasks+=("$task")
done < <(load_tasks)
if [ "${#tasks[@]}" -eq 0 ]; then
  tasks=(shell)
fi

render() {
  printf '\e[H\e[2J'
  cat <<EOF

  ${CY}   ████  ████▄  ${R}   ${GR}⚡${R} ${D}zellij + Claude Code dev template${R}
  ${CY}▄▄▄ ▀███▄ ▀███▄ ${R}   ${D}you're inside the${R} ${B}Minimal${R} ${D}sandbox${R}
  ${CY}▀███  ▀███  ▀███${R}
  ${GY}────────────────────────────────────────────────────────${R}

  ${PK}▸ tasks${R}  ${D}Up/Down or j/k to select, Enter to run${R}
EOF

  local i task marker command description disabled
  for i in "${!tasks[@]}"; do
    task=${tasks[$i]}
    command="min run $task"
    description=$(task_description "$task")
    disabled=""

    if [ "$task" = "dev" ]; then
      description="current zellij session"
      disabled=" ${D}(active)${R}"
    fi

    if [ "$i" -eq "$selected" ]; then
      marker="${YW}›${R}"
      printf '  %s %s%-24s%s %s%s%s\n' "$marker" "$B" "$command" "$R" "$D" "$description" "$R$disabled"
    else
      marker="${GY} ${R}"
      printf '  %s %s%-24s%s %s%s%s\n' "$marker" "$B" "$command" "$R" "$D" "$description" "$R$disabled"
    fi
  done

  cat <<EOF

  ${PK}▸ sandbox${R}
    ${B}min add${R}  ${GY}<pkg>${R}       ${D}install a package for this session${R}
    ${B}min search${R} ${GY}<term>${R}    ${D}find a package by name${R}

  ${GY}quit zellij: ${R}${B}Ctrl-q${R}   ${GY}·   detach: ${R}${B}Ctrl-o${R} ${GY}then${R} ${B}d${R}
EOF

  if [ -n "$status" ]; then
    printf '\n  %s%s%s\n' "$GR" "$status" "$R"
  fi
}

move_selection() {
  local direction=$1
  local count=${#tasks[@]}

  if [ "$direction" = "up" ]; then
    selected=$(( (selected + count - 1) % count ))
  else
    selected=$(( (selected + 1) % count ))
  fi
}

run_selected_task() {
  local task=${tasks[$selected]}

  if [ "$task" = "dev" ]; then
    status="Already inside the dev session."
    return
  fi

  printf '\e[H\e[2J'
  printf '\n  %sRunning:%s %smin run %s%s\n\n' "$GY" "$R" "$B" "$task" "$R"
  min run "$task"
  local exit_code=$?
  printf '\n  %sTask finished. Press any key to return to tasks.%s' "$D" "$R"
  IFS= read -rsn1 _
  if [ "$exit_code" -eq 0 ]; then
    status="Finished: min run $task"
  else
    status="Exited $exit_code: min run $task"
  fi
}

if [ ! -t 0 ] || [ ! -t 1 ]; then
  render
  exec sleep infinity
fi

while true; do
  render
  IFS= read -rsn1 key

  case "$key" in
    $'\e')
      IFS= read -rsn2 -t 1 key || true
      case "$key" in
        '[A') move_selection up ;;
        '[B') move_selection down ;;
      esac
      ;;
    k) move_selection up ;;
    j) move_selection down ;;
    '') run_selected_task ;;
  esac
done
