function! ReltimeToInt(reltime_val)
	let [sec, usec] = [a:reltime_val[0], a:reltime_val[1]]
	return sec * 1000000 + usec
endfunction

function! InitializeTabOrder()
	let current_time = ReltimeToInt(reltime())
	for tab in range(1, tabpagenr('$'))
		let g:tab_order[tab] = current_time
	endfor
endfunction

if !exists('g:tab_order')
	let g:tab_order = {}
	call InitializeTabOrder()
endif

augroup TabOrder
	autocmd!
	autocmd TabLeave * call UpdateTabOrder()
	autocmd TabNew * call HandleTabNew()
	autocmd TabClosed * call HandleTabClosed()
augroup END

function! UpdateTabOrder()
	let current_tab = tabpagenr()
	let g:tab_order[current_tab] = ReltimeToInt(reltime())  "current_time
endfunction

function! HandleTabNew()
	let new_tab = tabpagenr('$')
	let g:tab_order[new_tab] = ReltimeToInt(reltime())
	call UpdateTabNumbers()
endfunction

function! HandleTabClosed()
	let closed_tab =tabpagenr()
	if has_key(g:tab_order, closed_tab)
		call remove(g:tab_order, closed_tab)
	endif
	call UpdateTabNumbers()
endfunction

function! UpdateTabNumbers()
	let updated_order = {}
	let tab_list = sort(keys(g:tab_order), {a, b -> a - b})
	for new_tab in range(1, len(tab_list))
		let old_tab = tab_list[new_tab - 1]
		let updated_order[new_tab] = g:tab_order[old_tab]
	endfor
	let g:tab_order = updated_order
endfunction

function! GetSortedTabs()
	let sorted_tabs = sort(items(g:tab_order), {a, b -> b[1] - a[1]})
	return map(sorted_tabs, 'v:val[0]')
endfunction

function! leaderf#tabs#ShowSortedTabs()
	let sorted_tabs = GetSortedTabs()
	echo "Recent tabs (most recent first):"
	for tab in sorted_tabs
		let timestamp =g:tab_order[tab]
		echo 'Tab ' . tab . ' (Last used: ' . timestamp . ' seconds)'
	endfor
endfunction

function! SwitchToMostRecentTab()
	let sorted_tabs = GetSortedTabs()
	if len(sorted_tabs) > 1
		execute 'tabnext ' . sorted_tabs[1]
	else
		echo "No recent tabs found."
	endif
endfunction


function! leaderf#tabs#source(args) abort
	let current_tab = tabpagenr()
	let total_tabs = tabpagenr('$')
	let result = []
	let sorted_tabs = GetSortedTabs()
	echo "Recent tabs (most recent first):"
	for tabnr in sorted_tabs

		"for tabnr in range(1, total_tabs)
		let is_current = tabnr == current_tab
		let buflist = tabpagebuflist(tabnr)
		let window_count = len(buflist)
		let bufname = bufname(buflist[0])
		if bufname == ''
			let bufname = '[No Name]'
		else
			let bufname = fnamemodify(bufname, ':t')
		endif
		if is_current == ''
			let line = printf('%d:  %s', tabnr,  bufname)
			let line = is_current ? '> ' . line : '  ' . line
			call add(result, line)
		endif
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

