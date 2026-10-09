# Amber Fish Prompt v1.1 — angular pixel-fantasy status bar.
# Loaded AFTER existing config.fish, never touches Crylia files.
# Layout: compact (2 lines) or framed (4 lines):
#     set -g AMBER_FISH_STYLE framed
# Colors follow Amber Theme Bank on each next shell prompt.

function __amber_fish_load_palette
    set -l project "$HOME/Rice/amber"
    if set -q AMBER_PROJECT; and test -n "$AMBER_PROJECT"
        set project "$AMBER_PROJECT"
    end
    set -l helper "$project/scripts/fish/amber_palette.py"
    set -l vals
    if command -sq python3; and test -r "$helper"
        set vals (command python3 "$helper" 2>/dev/null)
    end
    if test (count $vals) -ge 8
        set -g __amber_fish_bg       $vals[1]
        set -g __amber_fish_surface  $vals[2]
        set -g __amber_fish_border   $vals[3]
        set -g __amber_fish_muted    $vals[4]
        set -g __amber_fish_accent   $vals[5]
        set -g __amber_fish_text     $vals[6]
        set -g __amber_fish_git      $vals[7]
        set -g __amber_fish_git_edge $vals[8]
    else
        # Fallback is First Flame. No errors printed into the prompt.
        set -g __amber_fish_bg       211A17
        set -g __amber_fish_surface  352820
        set -g __amber_fish_border   644A35
        set -g __amber_fish_muted    AD7650
        set -g __amber_fish_accent   DAA45C
        set -g __amber_fish_text     E8D4B2
        set -g __amber_fish_git      A8A097
        set -g __amber_fish_git_edge 888078
    end
end

function __amber_fish_segment -a label outline ink
    # Unicode angular caps. One-line text-only approximation of the mockup.
    printf '%s' (set_color $outline) '⟪' (set_color $ink) " $label " (set_color $outline) '⟫' (set_color normal) ' '
end

function __amber_fish_draw_framed
    # Full square-outline variant with real top and bottom borders.
    # Called with labels and colors stored in global temp vars by fish_prompt.
    set -l count (count $__amber_fish_labels)
    for i in (seq $count)
        set -l n (math (string length -- "$__amber_fish_labels[$i]") + 2)
        printf '%s%s%s' (set_color $__amber_fish_edges[$i]) '┌' (string repeat -n $n '─')
        printf '%s' '┐' (set_color normal) ' '
    end
    printf '\n'
    for i in (seq $count)
        printf '%s' (set_color $__amber_fish_edges[$i]) '│' (set_color $__amber_fish_inks[$i]) " $__amber_fish_labels[$i] " (set_color $__amber_fish_edges[$i]) '│' (set_color normal) ' '
    end
    printf '\n'
    for i in (seq $count)
        set -l n (math (string length -- "$__amber_fish_labels[$i]") + 2)
        printf '%s%s%s' (set_color $__amber_fish_edges[$i]) '└' (string repeat -n $n '─')
        printf '%s' '┘' (set_color normal) ' '
    end
    printf '\n'
end

function fish_prompt
    set -l last_status $status
    __amber_fish_load_palette

    set -l host (command hostname -s 2>/dev/null)
    if test -z "$host"
        set host 'host'
    end
    set -l who (whoami 2>/dev/null)
    if test -z "$who"
        set who 'user'
    end
    set -l user_segment "♨  $who@$host"
    set -l path_segment "▣  "(prompt_pwd)

    set -l git_segment ''
    if command -sq git
        set -l branch (command git symbolic-ref --short -q HEAD 2>/dev/null)
        if test -z "$branch"
            set branch (command git rev-parse --short HEAD 2>/dev/null)
        end
        if test -n "$branch"
            set git_segment "⑂  $branch"
        end
    end

    # Display Python environment only when active. Otherwise, no extra segment.
    set -l python_segment ''
    if set -q VIRTUAL_ENV; and test -n "$VIRTUAL_ENV"
        set -l venv_name (command basename -- "$VIRTUAL_ENV")
        set python_segment "py  $venv_name"
    else if set -q CONDA_DEFAULT_ENV; and test -n "$CONDA_DEFAULT_ENV"
        set python_segment "py  $CONDA_DEFAULT_ENV"
    end
    set -l time_segment '⌛  '(command date '+%H:%M')

    # Responsive: keep path, branch and Python; hide the clock first.
    set -l terminal_width 120
    if set -q COLUMNS; and string match -qr '^[0-9]+$' -- "$COLUMNS"
        set terminal_width $COLUMNS
    end
    set -l rough_length (math (string length -- "$user_segment$path_segment$git_segment$python_segment$time_segment") + 26)
    if test $rough_length -gt $terminal_width
        set time_segment ''
    end
    set rough_length (math (string length -- "$user_segment$path_segment$git_segment$python_segment") + 22)
    if test $rough_length -gt $terminal_width
        set python_segment ''
    end
    set rough_length (math (string length -- "$user_segment$path_segment$git_segment") + 18)
    if test $rough_length -gt $terminal_width
        set user_segment "♨  $who"
    end
    set rough_length (math (string length -- "$user_segment$path_segment$git_segment") + 18)
    if test $rough_length -gt $terminal_width; and test -n "$git_segment"
        set git_segment (string sub -s 1 -l 21 -- "$git_segment")'…'
    end

    set -g __amber_fish_labels "$user_segment" "$path_segment"
    set -g __amber_fish_edges $__amber_fish_accent $__amber_fish_accent
    set -g __amber_fish_inks $__amber_fish_text $__amber_fish_accent
    if test -n "$git_segment"
        set -a __amber_fish_labels "$git_segment"
        set -a __amber_fish_edges $__amber_fish_git_edge
        set -a __amber_fish_inks $__amber_fish_git
    end
    if test -n "$python_segment"
        set -a __amber_fish_labels "$python_segment"
        set -a __amber_fish_edges $__amber_fish_accent
        set -a __amber_fish_inks $__amber_fish_text
    end
    if test -n "$time_segment"
        set -a __amber_fish_labels "$time_segment"
        set -a __amber_fish_edges $__amber_fish_accent
        set -a __amber_fish_inks $__amber_fish_text
    end

    if set -q AMBER_FISH_STYLE; and test "$AMBER_FISH_STYLE" = framed
        __amber_fish_draw_framed
    else
        printf '%s' (set_color $__amber_fish_border) '┌─' (set_color normal) ' '
        for i in (seq (count $__amber_fish_labels))
            __amber_fish_segment "$__amber_fish_labels[$i]" $__amber_fish_edges[$i] $__amber_fish_inks[$i]
        end
        printf '\n'
    end
    printf '%s' (set_color $__amber_fish_border) '└─' (set_color $__amber_fish_accent) '❯' (set_color normal) ' '
    if test $last_status -ne 0
        printf '%s' (set_color brred) "[!$last_status] " (set_color normal)
    end
end

# Old tide/starship right prompt is deliberately disabled when Amber is active.
function fish_right_prompt
end
