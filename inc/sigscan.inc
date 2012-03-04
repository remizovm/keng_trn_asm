proc _ScanPattern,ProcessHandle,pattern,mask,modname
locals
	pSize		dd ?
	allocAddress	dd ?
	endOfAlloc	dd ?
endl

     invoke	CreateToolhelp32Snapshot,8,[pID]
     mov	[mSnapshot],eax
     mov	[module.dwSize],sizeof.MODULEENTRY32
     invoke	Module32First,[mSnapshot],module
check_module:
     invoke	StrStrI,module.szModule,[modname]
     test	eax,eax
     jz 	next_module
;-------------------------------------------------------------------------------------------------------------
     push	ecx esi edi
     invoke	lstrlen,[pattern]
     inc	eax
     mov	[pSize],eax
     invoke	VirtualAlloc,0,[module.modBaseSize],MEM_COMMIT,PAGE_EXECUTE_READWRITE
     mov	[allocAddress],eax
     add	eax,[module.modBaseSize]
     dec	eax
     mov	[endOfAlloc],eax
     invoke	ReadProcessMemory,[phandle],[module.modBaseAddr],[allocAddress],[module.modBaseSize],0
     mov	edi,[allocAddress]
     mov	esi,[pattern]
MainLoop:
     xor	ecx,ecx
     jmp	Loop2
Search:
     mov	eax,[mask]
     mov	al,[eax+ecx]
     cmp	al,"x"
     jne	AB
     mov	al,[esi+ecx]
     mov	ah,[edi+ecx]
     cmp	al,ah
     jne	Bdnm
AB:
     inc	ecx
Loop2:
     cmp	ecx,[pSize]
     jne	Search
     mov	eax,edi
     sub	eax,[allocAddress]
     add	eax,[module.modBaseAddr]
     push	eax
     invoke	VirtualFree,[allocAddress],[module.modBaseSize],MEM_DECOMMIT
     pop	eax
     ret
Bdnm:
     cmp	edi,[endOfAlloc]
     jnb	OutOfScanRange
     inc	edi
     jmp	MainLoop
OutOfScanRange:
     mov	eax,-1
     push	eax
     invoke	VirtualFree,[allocAddress],[module.modBaseSize],MEM_DECOMMIT
     pop	eax
     pop	ecx esi edi
     ret
;-------------------------------------------------------------------------------------------------------------
next_module:
     invoke	Module32Next,[mSnapshot],module
     test	eax,eax
     jnz	check_module
     invoke	CloseHandle,[mSnapshot]
     ret
endp
