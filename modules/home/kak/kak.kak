# kak-lsp settings
evaluate-commands %sh{ kak-lsp --kakoune -s $kak_session }
set-option global lsp_diagnostic_line_error_sign '║'
set-option global lsp_diagnostic_line_warning_sign '┊'
set-option global lsp_auto_highlight_references true
set-option global lsp_hover_anchor false

map global user l ': enter-user-mode lsp<ret>' -docstring "LSP mode"

hook global WinSetOption filetype=(python|clojure|haskell|rust|typescript|javascript) %{
    lsp-auto-hover-enable
    lsp-auto-signature-help-enable
    lsp-auto-hover-insert-mode-disable
    lsp-enable-window
}

# wrap
declare-option int wrapcol 80
declare-option -hidden bool wrapcol_displayed false

define-command highlight-wrapcol %{
    set-option window autowrap_column %opt{wrapcol}
    remove-highlighter window/wrapcol
    add-highlighter window/wrapcol column \
                    %sh{ echo $(( $kak_opt_wrapcol + 1 )) } \
                    LineNumberCursor
    unalias window toggle-highlight-wrapcol
    alias window toggle-highlight-wrapcol no-highlight-wrapcol
    set-option window wrapcol_displayed true
}
define-command no-highlight-wrapcol %{
    set-option window autowrap_column %opt{wrapcol}
    remove-highlighter window/wrapcol
    unalias window toggle-highlight-wrapcol
    alias window toggle-highlight-wrapcol highlight-wrapcol
    set-option window wrapcol_displayed false
}
hook global WinCreate .* %{
    alias window toggle-highlight-wrapcol highlight-wrapcol
}
map global user m ": toggle-highlight-wrapcol<ret>" -docstring 'toggle display wrapcol'
hook global WinSetOption wrapcol=.* %{
	evaluate-commands %sh{
    	if [ "$kak_opt_wrapcol_displayed" = "true" ]; then
    		printf 'highlight-wrapcol\n'
    	fi
	}
}

declare-option bool autowrap false

hook global WinSetOption autowrap=true %{
    hook -group autowrap window InsertChar [^\n] %{ try %{
        execute-keys -draft "hGh<a-k>.{%opt{wrapcol},}<ret><a-;><a-b>i<ret><esc>"
    } }
}
hook global WinSetOption autowrap=false %{ try %{
    remove-hooks window autowrap
} }

define-command wrap %{
    evaluate-commands %sh{
        format_cmd="$(printf %s "${kak_opt_autowrap_fmtcmd}" \
            | sed 's/%c/${kak_opt_autowrap_column}/g')"
        printf %s "
            evaluate-commands -draft %{
                execute-keys <a-x><a-j> '| ${format_cmd}<ret>'
                try %{ execute-keys s\h+$<ret> d }
            }
            select '${kak_reg_m}'
        "
    }
}

map global user w :wrap<ret> -docstring 'hard wrap selection'

# appearance settings
colorscheme adrusi
set-option -add global ui_options terminal_assistant=none "terminal_padding_char= "

define-command -hidden adrusi-number-lines %{
    add-highlighter window/number-lines number-lines -separator '│ '
    unalias window adrusi-toggle-linenumber
    alias window adrusi-toggle-linenumber adrusi-no-number-lines
}
define-command -hidden adrusi-no-number-lines %{
    remove-highlighter window/number-lines
    unalias window adrusi-toggle-linenumber
    alias window adrusi-toggle-linenumber adrusi-number-lines
}
hook global WinCreate .* %{
    alias window adrusi-toggle-linenumber adrusi-number-lines
}
map global user n ": adrusi-toggle-linenumber<ret>" -docstring 'toggle line numbers'

hook global WinCreate .* no-highlight-wrapcol

# copypasta
map global user y ': osc52-copy %val{register}<ret>' -docstring 'copy to system clipboard'
map global user p ': osc52-paste %val{register}<ret>' -docstring 'paste from system clipboard'

# commenting
define-command -hidden adrusi-comment-line %{
    try %{
        comment-line
    } catch %{
        try %{
            evaluate-commands -draft %{
                execute-keys <a-s>
                comment-block
            }
        } catch %{
            evaluate-commands -draft %{
                execute-keys xH
                comment-block
            }
        }
    }
}
map global user c ': adrusi-comment-line<ret>' -docstring 'comment lines'

# soft-wrap by default because the line scrolling is usually just annoying
hook global WinCreate .* %{
    add-highlighter window/softwrap wrap -indent -marker "↳"
}

# linting
define-command lint-on-save-enable %{
    hook -group lint-on-save buffer BufWritePost .* lint
}
define-command lint-on-save-disable %{
    remove-hooks buffer lint-on-save
}

# tab/shift-tab for navigating completions
hook global InsertCompletionShow .* %{ try %{
    execute-keys -draft hGh<a-K>\A\h+\z<ret>
    map window insert <tab> <c-n>
    map window insert <s-tab> <c-p>
} }
hook global InsertCompletionHide .* %{
    unmap window insert <tab> <c-n>
    unmap window insert <s-tab> <c-p>
}

# tools client
define-command set-toolsclient -params 0..1 %{ evaluate-commands %sh{
    if [ $# -eq 0 ]; then
        printf '%s\n' "set-option global toolsclient %val{client}"
    else
        printf '%s\n' "set-option global toolsclient '$1'"
    fi
} }

map -docstring "set as toolsclient" global user t ': set-toolsclient<ret>'

# grep
set-option global grepcmd "rg --line-number --follow --"

# indent
declare-option bool soft_tabs false
declare-option int indentwidth 4
declare-option int tabstop 4

hook global WinSetOption soft_tabs=true %{
    hook -group softtab window InsertChar \t %{ try %{
        execute-keys -draft "h<a-h><a-k>\A\h+\z<ret><a-;>;%opt{indentwidth}@"
    } }

    hook -group softtab window InsertDelete ' ' %{ try %{
        execute-keys -draft 'h<a-h><a-k>\A\h+\z<ret>i<space><esc><lt>'
    } }
}

hook global WinSetOption soft_tabs=false %{
    remove-hooks window softtab
}

# filetype
hook global BufCreate .*[.]sway %{
    set-option buffer filetype i3
}
hook global WinSetOption filetype=clojure %{
    set-option window soft_tabs true
    set-option window indentwidth 2
    remove-highlighter window/wrapcol
    remove-highlighter window/softwrap
    add-highlighter window/softwrap wrap -word -indent -marker "⤷"
    parinfer-enable-window -smart
}
hook global WinSetOption filetype=go %{
    set-option window soft_tabs false
    set-option window tabstop 4
}
hook global WinSetOption filetype=grep %{
    remove-highlighter global/softwrap
}
hook global WinSetOption filetype=haskell %{
    set-option window soft_tabs true
    set-option window indentwidth 2
    set-option window wrapcol 100
}
hook global WinSetOption filetype=make %{
    set-option window soft_tabs false
}
hook global WinSetOption filetype=c %{
    set-option window soft_tabs true
    set-option window indentwidth 4
    set-option window wrapcol 80
}
hook global WinSetOption filetype=rust %{
    set-option window soft_tabs true
    set-option window wrapcol 120
}
hook global WinSetOption filetype=sh %{
    set-option window soft_tabs false
    set-option window tabstop 4
}
hook global WinSetOption filetype=typescript %{
    set-option window soft_tabs true
    set-option window wrapcol 100
}
hook global WinSetOption filetype=javascript %{
    set-option window soft_tabs true
    set-option window wrapcol 100
}
hook global WinSetOption filetype=zig %{
    set-option window soft_tabs true
    set-option window wrapcol 100
}
hook global WinSetOption filetype=rep %{
    remove-highlighter window/wrapcol
    remove-highlighter window/linenumbers
}
hook global WinSetOption filetype=python %{
    set-option window soft_tabs true
    set-option window wrapcol 79
    set-option window indentwidth 4
}
hook global WinSetOption filetype=kak %{
    set-option window soft_tabs true
    set-option window indentwidth 4
}
hook global WinSetOption filetype=nim %{
    set-option window soft_tabs true
    set-option window indentwidth 4
}
hook global WinSetOption filetype=nix %{
    set-option window soft_tabs true
    set-option window indentwidth 2
}

# kakoune scripting helpers

define-command -hidden define-command-force-override -params 2.. %{
    unalias global define-command define-command-force-override
    evaluate-commands %sh{
        . kak.inc.sh
        has_override=
        for arg in "$@"; do
            [ "-override" = "$arg" ] && has_override=1;
        done
        printf 'define-command '
        [ "$has_override" ] || printf %s '-override '
        kakcork "$@"
    }
    alias global define-command define-command-force-override
}

define-command -override evaluate-commands-from-selection %{
    unalias global def define-command
    alias global def define-command-force-override
    alias global define-command define-command-force-override

    evaluate-commands -itersel %{ evaluate-commands %val{selection} }

    unalias global define-command define-command-force-override
    unalias global def define-command-force-override
    alias global def define-command
}

define-command load-colorscheme-from-buffer %{
    evaluate-commands -draft %{
        execute-keys '%'
        try %sh{
            printf %s\\n "$kak_selection" | grep '^set-face\|^face'
        }
    }
}

hook global WinSetOption filetype=kak %{
    try %{
        evaluate-commands %sh{
            case "$(readlink -f "$kak_buffile")" in
            "$(readlink -f "$kak_config/colors")"*) : ;;
            *) printf 'fail "not a colorscheme"\n';;
            esac
        }

        palette-gutter
        hook -group colorscheme window NormalIdle .* %{
            load-colorscheme-from-buffer
            if-buf-changed %{
                nop %sh{ (
                    printf 'evaluate-commands -draft -client "%s" %%{
                        palette-gutter
                    }\n' "$kak_client" | kak -p "$kak_session"
                ) >/dev/null 2>&1 </dev/null & }
            }
        }

        hook -group colorscheme window WinSetOption filetype=.* %{
            remove-hooks window colorscheme
        }
    } catch %{
        evaluate-commands %sh{
            . kak.inc.sh
            if [ "$kak_error" != "not a colorscheme" ]; then
                printf "fail %s\n" "$(kakquote "$kak_error")"
            fi
        }
    }
    map window user <ret> ': evaluate-commands-from-selection<ret>' -docstring 'eval selection as kak commands'
}

# override all of rep's config lol

declare-option -hidden str rep_evaluate_output
declare-option -hidden str rep_namespace

define-command -override -hidden rep-find-namespace %{
    evaluate-commands -draft %{
        set-option buffer rep_namespace ''
        # Probably will get messed up if the file starts with comments
        # containing parens.
        execute-keys 'gkm'
        evaluate-commands %sh{
            ns=$(rep --port="@.nrepl-port@${kak_buffile-.}" -- "(second '$kak_selection)" 2>/dev/null)
            if [ $? -ne 0 ]; then
                printf 'fail "could not parse namespace"\n'
            else
                printf 'set-option buffer rep_namespace %s\n' "$ns"
            fi
        }
    }
}

define-command \
    -override \
    -params 0.. \
    -docstring %{rep-evaluate-selection: Evaluate selected code in REPL and echo result.
Switches:
  -namespace <ns>   Evaluate in <ns>. Default is the current file's ns or user if not found.} \
    rep-evaluate-selection %{
    evaluate-commands %{
        set-option global rep_evaluate_output ''
        try %{ rep-find-namespace }
        evaluate-commands -itersel -draft %{
            evaluate-commands %sh{
                add_port() {
                    if [ -n "$kak_buffile" ]; then
                        rep_command="$rep_command --port=\"@.nrepl-port@$kak_buffile\""
                    fi
                }
                add_file_line_and_column() {
                    anchor="${kak_selection_desc%,*}"
                    anchor_line="${anchor%.*}"
                    anchor_column="${anchor#*.}"
                    cursor="${kak_selection_desc#*,}"
                    cursor_line="${cursor%.*}"
                    cursor_column="${cursor#*.}"
                    if [ $anchor_line -lt $cursor_line ]; then
                        start="$anchor_line:$anchor_column"
                    elif [ $anchor_line -eq $cursor_line ] && [ $anchor_column -lt $cursor_column ]; then
                        start="$anchor_line:$anchor_column"
                    else
                        start="$cursor_line:$cursor_column"
                    fi
                    rep_command="$rep_command --line=\"$kak_buffile:$start\""
                }
                add_namespace() {
                    ns="$kak_opt_rep_namespace"
                    while [ $# -gt 0 ]; do
                        case "$1" in
                            -namespace) shift; ns="$1";;
                        esac
                        shift
                    done
                    if [ -n "$ns" ]; then
                        rep_command="$rep_command --namespace=$ns"
                    fi
                }
                filtered_kak_selection=$(printf '%s\n' "$kak_selection" | tr '\n' '\033' | sed -r 's/^[[:space:][:cntrl:]]*\([[:space:][:cntrl:]]*comment[[:space:][:cntrl:]]+(.*)\)[[:space:][:cntrl:]]*$/\1/' | tr '\033' '\n')
                error_file=$(mktemp)
                rep_command='value=$(rep'
                add_port
                add_file_line_and_column
                add_namespace "$@"
                rep_command="$rep_command"' -- "$filtered_kak_selection" 2>"$error_file" |sed -e "s/'"'"'/'"''"'/g")'
                eval "$rep_command"
                error=$(sed "s/'/''/g" <"$error_file")
                rm -f "$error_file"
                printf "set-option -add global rep_evaluate_output '%s'\n" "$value"
                [ -n "$error" ] && printf "fail '%s'\n" "$error"
            }
        }
        echo -- "%opt{rep_evaluate_output}"
    }
}

define-command \
    -override \
    -docstring %{rep-evaluate-file: Evaluate the entire file in the REPL.} \
    rep-evaluate-file %{
    evaluate-commands -draft %{
        execute-keys '%'
        rep-evaluate-selection -namespace user
    }
    echo -- "%opt{rep_evaluate_output}"
}

define-command \
    -override \
    -docstring %{rep-replace-selection: Evaluate selection and replace with result.} \
    rep-replace-selection %{
    rep-evaluate-selection %arg{@}
    evaluate-commands -save-regs r %{
        set-register r "%opt{rep_evaluate_output}"
        execute-keys '"rR'
    }
}

define-command \
    -override \
    -docstring %{rep-select-toplevel-form: Expand selection to the toplevel form.} \
    rep-select-toplevel-form %{
    try %{
        execute-keys '<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>(<a-a>('
    }
}

define-command \
    -override \
    -docstring %{rep-evaluate-toplevel-form: Evaluate the toplevel form in the repl.} \
    rep-evaluate-toplevel-form %{
    evaluate-commands -draft %{
        rep-select-toplevel-form
        rep-evaluate-selection
    }
}

declare-user-mode my-rep
map global user e ': enter-user-mode my-rep<ret>'
map -docstring 'evaluate toplevel form in the REPL' global my-rep e ': rep-evaluate-toplevel-form<ret>'
map -docstring 'evaluate the selection in the REPL' global my-rep s ': rep-evaluate-selection<ret>'
map -docstring 'evaluate this file in the REPL'     global my-rep f ': rep-evaluate-file<ret>'

# kitty
define-command -params 1.. -shell-completion -override kitty-os-terminal %{
    nop %sh{ {
        kitty @ launch --type=os-window -- "$@"
    } >/dev/null 2>/dev/null </dev/null & }
}
alias global terminal kitty-os-terminal
map global normal <c-n> ": kitty-os-terminal kak -c %val{session}<ret>"
