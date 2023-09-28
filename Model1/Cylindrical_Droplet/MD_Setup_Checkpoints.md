Reference Paper : https://pubs.acs.org/doi/full/10.1021/jp0268112  

On the Water−Carbon Interaction for Use in Molecular Dynamics Simulations of Graphite and Carbon Nanotubes

    T. Werder, J. H. Walther, R. L. Jaffe, T. Halicioglu, and P. Koumoutsakos

--------------------------------------------------------------------------------------------------------------------------------------
# fftool to generate input files for carrying MD simulation in LAMMPS

1. xyz files of graphite and water		

H2O.xyz  downloaded from http://materia.fisica.unimi.it/manini/dida/structures.html . One can just create  in gview and specify the bond and angle in the water model force field file.

graphite.cif downloaded from Materials Project Website


2.  Extend to appropriate size to neglet finite size effects. Remove Additional layers if it does not effect the property of study.

The first method of extension and then cleaving is quiet confusing as the super cell size becomes large. So , I opted for a 
personally easier choice og the second option.
 - Convert to a orthorhbic unit cell using atomsk initial.cif -orthogonal-cell final.cif
 - Cleave the edges such that no overlap occurs when PBC is applied
 - Extend the unit cell using edit unit cell option in vesta and click transform and change the diagonal indices to stretch in z and y directions
   as required
 - Cleave the edges to make sure that when PBC is applied , there would not be any overlap !

> If I go ahead with this this structure containing 2 layers of graphite , i can't see a way to specify that there is no bonds between the 2 layers. So , maybe Make each layer as a diffrent .xyz file and have .ff file for both. That should be correct. 

- Open the 2 layer graphite file in VESTA . Note that the interlayer distance is  3.90155 angstrom. C-C distance is 1.4245 angstrom.
- Peel of 1st llayer and save as graphite-A.xyx
- Peel of 2nd layer and save as graphite-B.xyz

 
3. Fetching and creaing .ff files

Check the fftool documentation for file format  https://github.com/paduagroup/fftool#force-field-file-format


> Note that LAMMPS real units take kcal/mol as input for energy while fftool requires Kj/mol. fftool will do the conversion to kcal/mol


For graphite , there are CC , CO , OH and CH bonds

3 Atom Types ( C , H , O )
2 Bond Types ( C-C , H-O ) . We can add C-H , C-O bonds if we want but they are unlikely.
2 Angle Types ( C-C and O-H) 
1 Dihedtal Type (C-C-C-C)


In the paper ,  most models are  based on a pairwise additive Lennard-Jones potential between the oxygen atoms of the water and the carbon
and H atoms of water and the Carbon.

Some models also include an electrostatic interaction between the partial charge sites on the water molecules and point quadrupole moments on the carbons.

Some models for Carbon-Water potential is based on mixing rules.

Some models used a flexible graphite surface.

> The details of each model is explained in the folder allocated for each model


The force fields considered in paper will just have ATOMS section for both materials graphite and water and once fftool creates the inut file ,
we can modify it to provide the LJ parameters for CO and OO interaction which are the only considered LJ interactions.`

4. Creating the simulation set up with packmol

- Water ocupies 30 armstrong cube roughly , for 1000 water molecules and leaving enough space both sides of graphite , watter 
  lattice size was chosen to be 65*65*7 armstrong. Hydrogen =-bond length is around 3 angstrom + considering the volume of water (a sphere with radius 1 angstrom) ,
  the volume occupied by water molecule is 30 +15.7 angstrom cubed

> For spherical droplets , need to provide enough vacuum in x and y  so 65*65*7 is alright.
> For cylindrical droplets , need to draw out interactions along one directions while ensuting no interaction in the other. So ,if you pack around 2000 water molecules , this would be approximately, 115*55*10


- 3 armstrong spacing between water layer and graphite.F
- Fix graphite_B at bottom 
- Fix Graphite A after leaving 3.4 interlayer distance
- The fixed command will lead to corner of the sheet to be origin. Just verify again.

11. Using inside box command command to fix graphite infact lead to some atoms in the top layer being out of plane and not overlapping with each other like expected in A-B stacking.
12.  fixed center command ensured that the atoms in graphite layers were in their respective place but the atoms did not overlap like in A-B stacking.
13. Finally just using fixed command lead to atoms overlapping like expected in A-B stacking and the atoms were in the same plane as in their respective layers , but the interlayer spacing was not correct despite fixing the second layer at 3.4.


> So , I decided to use sed and manually change the z coordinates in graphite-A and graphite-B
> sed 's/5\.852325/3\.4000/g' graphite-A.xyz > graphite-temp2.xyz . Finally all seems fine.

Then the 13. method worked , finally

> Always check the file with VESTA and see if the box dimensions , box edges  are making sense and there is no overlap between atoms if PBC is applied.



5. Creating a sample input file which later need to be modifed anyways

According to the paper , the force fields are considered for water as well as water carbon interaction only.
fftool -b x,y,z -l -a -p xy 1 graphite.xyz 1000 H20-SPC.xyz

> While setting the z , also add the vacuum needed in z direction

# LAMMPS  input script


 
Line by line explanation 

1. units real
time - fs  distance  - Angstrom  energy - kcal/mol  Temp  - Kelvin Pressure - atm
2. boundary  p p p 
Periodic in all 3 directions. To make sure periodic images dont interact , 20 armstrong vacuum provided at the top during simulation set up.

3. atom style full 
   bond_style zero nocoeff
   angle_style zero nocoeff


All styles store coordinates, velocities, atom IDs and types. In addition , the charge .

> There are no bond_style , angle_style and dihedral_style by construction of the model ? For graphite , no need maybe . May be its needed , if thats how LAMMPS know theat the atoms are bonded. 
> For water , it is SPC/E model . So, bonds and angles are fixed.  Just like graphite , no need to write bonds and angles in ff or that is the way lammps know that they are bonded.


zero means Using an bond style of zero means bond forces and energies are not computed, but the geometry of bond pairs is still accessible to other commands.

The nocoeff flag is to let lammps know that we won't specify bond coeff in lammps script , so read from data.lmp


4. special_bonds lj/coul w1 w2 w3 

Strength of pairwise interaction to be accounted for . 

The first of the 3 coefficients (LJ or Coulombic) is the weighting factor on 1-2 atom pairs, which are pairs of atoms directly bonded to each other. The second coefficient is the weighting factor on 1-3 atom pairs which are those separated by 2 bonds (e.g. the two H atoms in a water molecule). The third coefficient is the weighting factor on 1-4 atom pairs which are those separated by 3 bonds (e.g. the first and fourth atoms in a dihedral interaction). Thus if the 1-2 coefficient is set to 0.0, then the pairwise interaction is effectively turned off for all pairs of atoms bonded to each other. If it is set to 1.0, then that interaction will be at full strength.


> I guess ,since bonds , angles and dihedrals  are not considered in graphite but bonds and angles are considered for water. 

> Should LAMMPS know that they are bonded. Anyways , their interaction energy coefficients  are set to zero. Can I fix the bonds and angles of water with SHAKE and the entire graphite atom coordinates with SHAKE. That should work , I guess.


> Totally confused what value to set. Also , I now doubt whether the graphite force field file containing just ATOMS section is correct or not.


5. pair_style hybrid lj/cut/coul/long 10.0 10.0`

Set the formula(s) LAMMPS uses to compute pairwise interactions.

Cut off for all potentials is 10 angstrom. 

hybrid  - Hybrid models where specified pairs of atom types interact via different pair potentials can be setup using the _hybrid_ pair style.

, Here , they all atom types have  pair potentials related to lj and coulomb. That's it. So , I guess , no need of hybrid.


6. pair modify tail yes

Modify the parameters of the currently defined pair style

When the _tail_ keyword is set to _yes_, certain pair styles will add a long-range VanderWaals tail “correction” to the energy and pressure. These corrections are bookkeeping terms which do not affect dynamics, unless a constant-pressure simulation is being performed. See the page for individual styles to see which support this option.

> One might add tail corrections but it is not mention  in paper , so set as no ??


7. kspace_style pppm 1.0e-5

Define a long-range solver for LAMMPS to use each timestep to compute long-range Coulombic interactions or long-range interactions. Most of the long-range solvers perform their computation in K-space, hence the name of this command.

> Use pppm technique with accuracy of 1e-5.


8. read_data data.lmp 

This is one of 3 ways to specify initial atom coordinates.

9. pair_coeff 1 3  lj/cut/coul/long  epsilon sigma

Defines the coefficients of pair potential .  

10. neighbour 2 bin

This command sets parameters that affect the building of pairwise neighbor lists.

11. neighbour modify

This command sets parameters that affect the building and use of pairwise neighbor lists. This command is out of my scope , so not gonna use it for now.

12. Variable TK equal 300.0

Setting up variables  for reuse

- group H2O-SPC type 2 3

- group graphite type 1

- velocity H2O-SPC  create ${TK} 12345
Only water molecules are moving

- run 0  # temperature may not be 300K 
  velocity H2O-SPC  scale ${TK}     # now it should be

> Read https://docs.lammps.org/velocity.html

Basically , since we are employing the shake constraint , the assigned velocities get cancelled 
and won't end up at the desired tempearture."  A workaround for this is to perform a run 0 command, which ensures all DOFs are accounted for properly, and then rescale the temperature to the desired value before performing a simulation."

- fix C_atom_fix graphite setforce 0.0 0.0 0.0

Graphite atoms are nonvibrating
 
- velocity graphite set 0.0 0.0 0.0

Graphite atoms are not moving

- fix shake_H2O  H2O-SPC shake 0.0001 20 10 b 1 a 1 # shake-H2O is fix id .H2O-SPC is group id



> You can fix all the atoms position in LAMMPS , as in , it does not experience any force , so no vibration of atoms or translation/rotation of sheet
> There are ways to ensure that the sheet does not transate but the atoms vibrate too in LAMMPS.




-  fix TVSTAT all nvt temp Tstart Tstop Tdamp

In LAMMPS, a “fix” is any operation that is applied to the system during timestepping or minimization. Examples include
   - updating of atom positions and velocities due to time integration
   - controlling temperature, applying constraint forces to atoms,
   - enforcing boundary conditions, computing diagnostics.

Here , TVSTAT is the id of fix . all means it applies to all atoms. 
temp is the keyword of nvt style  .It takes 3 values , Tstart , Tstop ,and Tdamp_coefficient.
temp/berendsen makes use of berendsen thermostat but by default fix nvt uses Nose-Hoover


- thermo 10000
Output thermodynamics every n timesteps

- thermostyle

What all thermodynamic quantities needs to be printed.

evdwl = van der Waals pairwise energy (includes etail)
ecoul = Coulombic pairwise energy
elong = long-range kspace energy


-  run 2000

2 picosecond run if timestep is 1 fs.

-  unfix TVSTAT

As we are stopping NVT and switchin to NVER simulatiion

-  fix EVSTAT all nve

Run ps in NVE ensemble

- run ${equi_steps}

- dump TRAJ all custom 500 dump.lammpstrj id mol type element q xu yu zu

Need trajectories for droplet analysis method


- dump_modify TRAJ element C H O
naming 1,2,3 as C,H,O in dump file


- run ${total_steps}

self-explanatory

- write_data data.eq.lmp

self explanatory

-----

What is left  ? 
- Total carbon−oxygen Lennard-Jones interaction energy.
- water denity profile (compute rdf? )
- Need to dump trajectories after equilibriation. dump command comes after equilibriation , then this is ensured.








## [[Doubts]]

1. I did not include BONDS , ANGLES and DIHEDRALS in graphite force field as it is considered inert in the paper.  Will LAMMPS know somehow from structural files I provided that they are bonded.

- Probably , the structure file contains only the coordinates and the bonding need to be separately mentioned in the FF file for LAMMPS to know.

2. How does neighbor lists even work ?
