- ERROR on proc 0: Out of range atoms - cannot compute PPPM (src/KSPACE/pppm.cpp:1891)
Last command: run ${equi_steps}


> 	- Is there overlap , but used packmol.
	- Theoretically, these particles are moving way too far after certain time steps. 
	This may be caused by a large simulation box and a small cluster of molecules. 
	
        - Decreasing time-step from 2 to 1 fs did not help
	- Changing bond style to harmonic removed this but why? 

- No errors but the PE is nan

 The packing was wrong. Upon looking simbox.xyz , certain  C,C atom  should superimpose for A-B stacking was not observed. Manually edited and fixed it. Now could see it running.

- No run errors but graphite atom getting distorted as well as, temperature not correct in NVT , as well as spherical droplet formed when infact cylindrical droplet is expected.
  > Change bond style and run
  > Forgot to setforce equal to zero. It is necessary ?  , even if we are not integrating C positions.
  > Fix using the run 0 , and scaling as suggested in LAMMPS tutorial. 
