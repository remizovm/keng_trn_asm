.code
ScanPattern proc uses ecx esi edi pattern:dword,pattern_mask:dword,modulename:dword,pSize:dword;,pid:dword

LOCAL aSize:dword,aAddress:dword,EndofAlloc:dword,mSnapshot:dword,module:MODULEENTRY32,sAddress:dword,eAddress:dword,pHandle:dword

	invoke	CreateToolhelp32Snapshot,TH32CS_SNAPMODULE,pid
   	.if (eax != 0)
   		mov mSnapshot,eax
       	mov [module.dwSize],sizeof module
       	invoke Module32First,mSnapshot,addr module
       	.if (eax)
       	@@:
        	invoke lstrcmpi,modulename,addr module.szModule
           	.if (eax == 0)    
;SCAN=================================================================================================
    			;push ecx
    			;push esi
    			;push edi        	
				;mov	pSize,sizeof pattern
				push 	module.modBaseAddr
				pop		sAddress	
				push 	module.modBaseSize
				pop 	aSize	; how much must we allocate	
				mov 	eax,module.modBaseAddr
				add 	eax,module.modBaseSize
				mov 	eAddress,eax
				;mov eax,EndAddy
	;sub eax,StartAddy	; eax now size to alloc
	;mov AllocSize,eax	; how much must we allocate

	invoke VirtualAlloc,0,aSize,MEM_COMMIT,PAGE_EXECUTE_READWRITE
	mov aAddress,eax	; adresse of allocated mem
	
	add eax,aSize
	dec eax			; last addr must be dec  (or its@newsection)
	mov EndofAlloc,eax	; End of allocated mem

	invoke OpenProcess,PROCESS_ALL_ACCESS,NULL,pid
	push	eax
	invoke ReadProcessMemory, eax, sAddress, aAddress, aSize, 0  ;map all	 (mapping is fast)
	pop eax
	invoke CloseHandle,eax
	mov edi,aAddress
	mov esi,pattern		

	.WHILE 1
		xor ecx,ecx
		.while ecx!=pSize
			mov eax,pattern_mask     ; here we check for Notation "x"
			mov al,[eax+ecx]
			cmp al,"x"
			jne AB

			mov al,[esi+ecx]
			mov ah,[edi+ecx]
			cmp al,ah		;lets compare our bytes
			jne Bdnm		;if something doesnt match jump out  Bytesdoesntmatch(Bdnm)
		AB:
			inc ecx
		.endw

		mov eax,edi			;--we found it
		sub eax,aAddress
		add eax,sAddress
		push eax
		invoke VirtualFree,aAddress,aSize,MEM_DECOMMIT
		;invoke 	CloseHandle, mSnapshot	
		pop eax
		ret
		
	Bdnm:
		cmp edi,EndofAlloc		;check if are at the section End
		jae OutOfScanRange		;if so no signature found
		
		inc edi
	.ENDW
OutOfScanRange:

	mov eax,-1
	push eax
	invoke VirtualFree,aAddress,aSize,MEM_DECOMMIT	
	pop eax
				ret
;SCAN=================================================================================================				
           	.endif
           	invoke 	Module32Next, mSnapshot,ADDR module
           	test 	eax,eax
           	jnz 	@B       
       	.endif
       	invoke 	CloseHandle, mSnapshot   
   	.endif
   	ret	
ScanPattern EndP