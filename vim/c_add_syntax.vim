syn match cOperator display '[+-/%.?:!*&]'
syn match cOperator display '->'
syn match cOperator display '||'
syn match cOperator display '<<'
syn match cOperator display '>>'
syn match cDelimiter display '[;,]'
syn match cDelimiter display '[{}\[\]()]'
hi default cDelimiter cterm=bold ctermfg=Brown
