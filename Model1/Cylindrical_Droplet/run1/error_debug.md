- ERROR on proc 0: Out of range atoms - cannot compute PPPM (src/KSPACE/pppm.cpp:1891)
Last command: run ${equi_steps}


> 	- Is there overlap , but used packmol.
	- Theoretically, these particles are moving way too far after certain time steps. 
	This may be caused by a large simulation box and a small cluster of molecules. 
	
        - Decreasing time-step from 2 to 1 fs did not help 
