# zmx list uses tabs between fields; values may contain spaces and '='.
def "zml parse" []: string -> list<record> {
    lines
    | where {|line| ($line | str trim) != "" }
    | each {|line|
        $line | str trim --left | split row "\t"
        | reduce --fold {} {|field, row|
            let pair = $field | split row --number 2 '='
            if ($pair | length) != 2 {
                error make {msg: $"Invalid zmx list field: ($field)"}
            }
            $row | insert $pair.0 $pair.1
        }
    }
}

def "zml rows" []: list<record> -> list<record> {
    let sessions = $in
    let now = date now
    let home = '~' | path expand
    $sessions | each {|session|
        let cwd = $session.cwd? | default ""
        let directory = if ($cwd | str starts-with 'file://') {
            $cwd | url parse | get path | url decode
        } else { $cwd }
        let directory = if $directory == $home { '~' } else if (
            $directory | str starts-with $"($home)/"
        ) { $"~($directory | str substring ($home | str length)..)" } else { $directory }
        let age = if ($session.created? | is-empty) { '?' } else {
            $now - (($session.created | into int) * 1_000_000_000 | into datetime)
            | into int
            | $in // 1_000_000_000
            | into duration --unit sec
            | into string
        }
        {
            NAME: $session.name
            STATUS: (if (($session.clients? | default '0' | into int) > 0) { 'Attached' } else { 'Detached' })
            AGE: $age
            DIRECTORY: $directory
            session: $session
        }
    }
}

def "zml preview" [row: record]: nothing -> string {
    let session = $row.session
    let details = $session
        | reject --optional name created cwd
        | transpose key value
        | each {|field| $"($field.key): ($field.value)" }
        | str join "\n"
    # The session name must precede history options in zmx.
    let screen = ^zmx history $session.name --screen | complete
    let content = if $screen.exit_code == 0 { $screen.stdout } else {
        $"[history unavailable] ($screen.stderr | str trim)"
    }
    $"($details)\n\n($content)"
}

def "zml ui" []: list<record> -> any {
    tui label --titlebar 'zmx sessions'
    | tui search --bind / --fuzzy --columns [NAME STATUS DIRECTORY] --placeholder 'Search sessions'
    | tui split --vertical --sizes [40% 1fr] [
        (tui table --id sessions --focus --title Sessions --columns [NAME STATUS AGE DIRECTORY])
        (tui preview --from sessions --title Screen {|row| zml preview $row })
    ]
    | tui label --status 'j/k: select  /: search  Enter: attach  q: quit'
}

def "zml attach" []: record -> nothing {
    let result = $in
    if $result.action == 'submit' and ($result.selected | is-not-empty) {
        ^zmx attach $result.selected.session.name
    }
}

# Import with `use zml.nu`, then run `zml`.
export def main [] {
    ^zmx list
    | complete
    | do {|result|
        if $result.exit_code != 0 {
            error make {msg: $"zmx list failed: ($result.stderr | str trim)"}
        }
        $result.stdout
    } $in
    | zml parse
    | zml rows
    | zml ui
    | tui run
    | zml attach
}

