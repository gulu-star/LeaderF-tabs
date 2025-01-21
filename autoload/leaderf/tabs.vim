function! leaderf#tabs#source(args) abort
    let current_tab = tabpagenr()
    let total_tabs = tabpagenr('$')
    let result = []

    for tabnr in range(1, total_tabs)
        let is_current = tabnr == current_tab
        let buflist = tabpagebuflist(tabnr)
        let window_count = len(buflist)
        let bufname = bufname(buflist[0])
        if bufname == ''
            let bufname = '[No Name]'
        else
            let bufname = fnamemodify(bufname, ':t')
        endif
        let line = printf('%d:  %s', tabnr,  bufname)
        let line = is_current ? '> ' . line : '  ' . line
        call add(result, line)
    endfor

    return result
endfunction

function! leaderf#tabs#accept(line, args) abort
    let tabnr = matchstr(a:line, '\zs\d\+\ze:')
    if tabnr == ''
        echo "Failed to parse tab number"
        return
    endif

    let tabnr = str2nr(tabnr)
    if tabnr < 1 || tabnr > tabpagenr('$')
        echo "Invalid tab number:" tabnr
        return
    endif

    try
        execute tabnr.'tabnext'
    catch
        echo "Error switching tab:" v:exception
    endtry
endfunction

function! leaderf#tabs#preview(orig_buf_nr, orig_cursor, line, args) abort
    if a:line =~# '^Tab List'
        return []
    endif

    let tabnr = matchstr(a:line, '\zs\d\+\ze:')
    if tabnr == ''
        return []
    endif

    let tabnr = str2nr(tabnr)
    let buflist = tabpagebuflist(tabnr)
    if empty(buflist)
        return []
    endif

    return [buflist[0], 1, '']
endfunction

function! leaderf#tabs#bang_enter(orig_buf_nr, orig_cursor, args) abort
    call search('^>')
    redraw
endfunction

