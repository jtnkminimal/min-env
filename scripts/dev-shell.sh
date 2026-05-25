#!/usr/bin/env bash
# Banner pane for `min run dev`. Prints the project label + task shortcuts,
# then sleeps to keep the pane alive (the interactive shell lives in the
# sibling pane below).

if [ -t 1 ]; then
  R=$'\e[0m'    ; D=$'\e[2m'    ; B=$'\e[1m'
  CY=$'\e[38;5;87m'              # cyan      — brand
  PK=$'\e[38;5;213m'             # pink      — section headers
  GY=$'\e[38;5;245m'             # grey      — chrome
  GR=$'\e[38;5;120m'             # green     — accent
fi

cat <<EOF

  ${CY}   ████  ████▄  ${R}   ${GR}⚡${R} ${D}zellij + Claude Code dev template${R}
  ${CY}▄▄▄ ▀███▄ ▀███▄ ${R}   ${D}you're inside the${R} ${B}Minimal${R} ${D}sandbox${R}
  ${CY}▀███  ▀███  ▀███${R}
  ${GY}────────────────────────────────────────────────────────${R}

  ${PK}▸ tasks${R}  ${D}(define your own in${R} ${B}minimal.toml${R}${D})${R}
    ${B}min run dev${R}              ${D}this zellij session${R}
    ${B}min run claude${R}           ${D}Claude Code, standalone${R}
    ${B}min run shell${R}            ${D}plain interactive shell${R}

  ${PK}▸ sandbox${R}
    ${B}min add${R}  ${GY}<pkg>${R}       ${D}install a package for this session${R}
    ${B}min search${R} ${GY}<term>${R}    ${D}find a package by name${R}

  ${GY}quit zellij: ${R}${B}Ctrl-q${R}   ${GY}·   detach: ${R}${B}Ctrl-o${R} ${GY}then${R} ${B}d${R}

EOF

exec sleep infinity
