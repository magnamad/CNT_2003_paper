> Trying to reproduce case 5 of the paper. These are the key details in the model

### Structure of the model

- 2 sheets of graphite only considered
- 2000 water molecules arranged to result in a cylindrical drop configuration
- The length and breadth of the sheet Precisely 118.43040 in x , and 119.65800 in y. I extend 48 and 28 times the orthorhombic unit cell and cleaved appropriately the edge such that no overlap occurs upon PBC.   If you look at the VESTA file , there is a small correction it is 117.19675 * 118.94575 if you look at the x-most and y-most atoms.  However , that is not the super cell. supercell cell length remains 48  and  28 times unit cell in appropriate directions !
  
- The height of unit cell is 7.8310 

### Interactions


- Based on a pairwise additive Lennard-Jones potential between the oxygen atoms of the water and the carbon for water -carbon interactions.

sigma C-O = 3.190 Armstron  and epsilon C-O  0.3135 kJ mol-1 

- Rigid extended Simple Point Charge Potential SPC/E for water-water interactions.
  -  smoothly truncated Coulomb potential acting between oxygen and hydrongen.
  -  partial point charges on the oxygen (−0.8476e) and hydrogen (+0.4238e) atoms 
  -  O−O Lennard-Jones interaction with εOO = 0.6502 kJ mol-1 and σOO = 3.166 Å


- O-H bond and H-O-H angle are fixed at 1 Armstrong and 109.42 degrees  using SHAKE  

-  Graphite atoms are fixed in their respective positions.

-   Cutoff for all potential is 10 Armstrong

### Other technical aspects

- 1 ns simulation
- timestep is 2fs
- first 100 ps equilbriation using  Berenden Thermostat  at 300 K temperature
- Then , 100 ps equilbriation aplying constnat energy
- Sampling also with constant energy simulation


### Initial Geometry
- Considering 30 armstong cve as vlume occupied by water, 30000 total volume is required
- The initial packing is a cuve of height 7 armstrong and length and breadth as  65  armstrong respectively
- 3 armstrong spacing between water layer and graphite
- 22 armstrong vacuum above water too  
