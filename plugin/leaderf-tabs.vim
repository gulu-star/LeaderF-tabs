if !exists("g:Lf_Extensions")
    let g:Lf_Extensions = {}
endif

let g:Lf_Extensions.tabs = {
            \ "source": "leaderf#tabs#source",
            \ "accept": "leaderf#tabs#accept",
            \ "preview": "leaderf#tabs#preview",
            \ "bang_enter": "leaderf#tabs#bang_enter",
            \ "highlights_def": {
            \         "Lf_hl_TabsNumber":':\@<!\d\+:',   
            \         "Lf_hl_TabsInfo": ': \zs.*',
            \ },
            \ "highlights_cmd": [
            \         "hi link Lf_hl_TabsNumber Number",
            \         "hi link Lf_hl_TabsInfo Comment",
            \ ],
            \ }

command! -bar -nargs=0 LeaderfTabs Leaderf tabs

let g:Lf_SelfContent = get(g:,'Lf_SelfContent', {})
let g:Lf_SelfContent['LeaderfTabs'] = "vim tab list"
