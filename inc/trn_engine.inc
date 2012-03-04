proc ActivateTrn
     call	GetProcess
     invoke	ScanPattern,[phandle],option1_pattern,option1_mask,option1_module
     invoke	Beep,500,500
     ret
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
     ;invoke     ScanPattern,[phandle],option1_pattern,18,option1_mask,option1_module
     ret
endp

;TODO:
;CreateCave

proc GetMemForCave,size
     inc	[size] ; +1 byte for ret command
     invoke	VirtualAllocEx,[phandle],NULL,size,MEM_COMMIT,PAGE_EXECUTE_READWRITE
     ret
endp

proc WriteCave,aT,aF,bytecode_size
	mov	eax,[aT]
	sub	eax,[aF]
	sub	eax,5
	mov	[buffer],0xE8
	mov	[buffer+1],al
	mov	[buffer+2],ah
	shr	eax,16
	mov	[buffer+3],al
	mov	[buffer+4],ah
	mov	eax,[bytecode_size]
	sub	eax,5
	cmp	eax,0 
	je	@exit
	@noploop: 
	mov	[buffer + sizeof buffer + eax],0x90
	dec	eax
	cmp	eax,0
	jne	@noploop
	@exit:
	invoke	WriteProcessMemory,[phandle],[aF],[buffer],[bytecode_size],NULL
	ret
endp

proc CreateCave,option_pattern,option_mask,option_cave_bytecode,option_found_address
.aT dd ?
.aF dd ?
	
	invoke	ScanPattern,[phandle],option1_pattern,18,option1_mask,option1_module
	mov	[option_found_address],eax
	mov	[aF],eax
	invoke	GetMemForCave,sizeof option_cave_bytecode
	mov	[aT],eax
	mov	[option_cave_bytecode + sizeof option_cave_bytecode],0xC3
	invoke	WriteProcessMemory,[phandle],[aT],[option_cave_bytecode],[sizeof option_cave_bytecode + 1],NULL
	ret
endp











