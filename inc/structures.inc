struct PROCESSENTRY32
       dwSize			dd ?
       cntUsage 		dd ?
       th32ProcessID		dd ?
       th32DefaultHeapID	dd ?
       th32ModuleID		dd ?
       cntThreads		dd ?
       th32ParentProcessID	dd ?
       pcPriClassBase		dd ?
       dwFlags			dd ?
       szExeFile		db 260 dup(?)
ends

struct MODULEENTRY32
	dwSize			dd ?   
	th32ModuleID		dd ? 
	th32ProcessID		dd ? 
	GlblcntUsage		dd ? 
	ProccntUsage		dd ? 
	modBaseAddr		dd ?   
	modBaseSize		dd ? 
	hModule 		dd ?
	szModule		rb 260 
	szExePath		rb 1024
ends