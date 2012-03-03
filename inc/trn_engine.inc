proc ActivateTrn
     ;call       FindProcess
     invoke	ScanPattern,[phandle],[option1_startaddress],[option1_endaddress],option1_pattern,18,option1_mask ;18 - length of pattern
endp

proc GetProcess
     mov	[prcs.dwSize],sizeof.PROCESSENTRY32
     invoke	CreateToolhelp32Snapshot,2,0
     mov	[hSnapshot],eax
     invoke	Process32First,[hSnapshot],prcs
search_loop:
     mov	edi,PrcList
     invoke	StrStrI,prcs.szExeFile,edi
     cmp	eax,0
     jne	found
next_proc:
     invoke	Process32Next,[hSnapshot],prcs
     cmp	eax,0
     jne	search_loop
     invoke	CloseHandle,[hSnapshot]
     ret
found:

     invoke	OpenProcess,PROCESS_ALL_ACCESS,0,[prcs.th32ProcessID]
     mov	[phandle],eax
     push	[prcs.th32ProcessID]
     pop	[pID]
     mov	[trn_flag],1
     invoke	CloseHandle,[hSnapshot]
     ;push       base
     ;push       size
     ;push       dllname
     ;call       GetProcessModule
     invoke	ScanPattern,[phandle],option1_pattern,18,option1_mask,option1_module
     invoke	Beep,1000,100
     ;invoke     Beep,1000,100
     ret
endp

;proc GetProcessModule,dllname
;     invoke     CreateToolhelp32Snapshot,8,[pID]
;     mov        [mSnapshot],eax
;     mov        [module.dwSize],sizeof.MODULEENTRY32
;     invoke     Module32First,[mSnapshot],module
;check_module:
;     invoke     StrStrI,module.szModule,[dllname]
;     test       eax,eax
;     jz         loop_search
;     invoke     ScanPattern,[phandle],option1_pattern,18,option1_mask,[module.modBaseAddr],[module.modBaseSize],[dllname]
;     invoke     Beep,1000,100
;loop_search:
;     invoke     Module32Next,[mSnapshot],module
;     test       eax,eax
;     jnz        check_module
;     invoke     CloseHandle,[mSnapshot]
;     ret
;endp




