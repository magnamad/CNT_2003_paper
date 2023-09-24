export OMP_NUM_THREADS=2
mpiexec -np 12 lmp -in in.lmp
