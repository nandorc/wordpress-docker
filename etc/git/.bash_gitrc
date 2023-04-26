#!/bin/bash

# Show git branch name
force_color_prompt=yes
color_prompt=yes
function parse_git_branch() {
    # Variables
    declare has_colors result tmp
    has_colors=$1
    [ "${has_colors}" != "0" ] && [ "${has_colors}" != "1" ] && has_colors=0
    # Check branch
    result=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    # Check git statuses
    [ -n "${result}" ] && [ -f .git/MERGE_HEAD ] && result="${result} | Merging"
    [ -n "${result}" ] && [ -f .git/CHERRY_PICK_HEAD ] && result="${result} | Cherry-Picking"
    # Return result
    [ -n "${result}" ] && [ ${has_colors} -eq 1 ] && result="\e[01;31m${result}\e[00m"
    [ -n "${result}" ] && result="${result}:"
    echo -e "${result}"
}
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\e[01;32m\]\u@\h\[\e[00m\]:$(parse_git_branch 1)\[\e[01;34m\]\w\[\e[00m\]\n\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:$(parse_git_branch)\w\n\$ '
fi

unset color_prompt force_color_prompt
