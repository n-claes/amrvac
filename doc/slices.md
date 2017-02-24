# Slice output

# Introduction

To alleviate the disk space requirements and overhead of full snapshot output,
it is possible to write hypersurfaces at their own (short) intervals.
Currently, these slices are aligned with the grid, with the benefit that only
a sub-space of the forest has to be traversed to obtain a Morton ordered AMR-
aware subgrid. The output is composed of the grid cells _closest_ to the
specified subdimensional plane and thus reflects non-interpolated simulation
variables which can be handy for debugging purposes.

## Setup in par file

D-1 dimensional slices are the third file format with output intervals that
can be specified in the _savelist_ section of the par file. To give an
example, here we specify three slices, where the first is perpendicular to the
first coordinate direction _(slicedir(1)=1)_ and intersects the first axis at
a value of 0.6 _(slicecoord(1)=0.6)_. The second plane is parametrized
perpendicular to the third coordinate direction _(slicedir(2)=3)_ and
intersects the third axis at a value of 0.8 _(slicecoord(2)=0.8)_ and analoge
for the third slice.

     &savelist;
            itsave(1,3)=0
            dtsave(3)=0.1d0
            nslices=3
            slicedir(1)=1
            slicecoord(1)=0.6
            slicedir(2)=3
            slicecoord(2)=0.8
            slicedir(3)=2
            slicecoord(3)=0.7
    /

The total number of slices is specified by _nslices_. The implementation
obtains a properly Morton ordered subdimensional forest with the same levels
as the original simulation, such that the output can be used for restarts in
lower dimension.

Currently there are three fileformats available for the slices.  These are:

1. _.dat_ files which are legacy MPI-AMRVAC snapshot files.  From these, the code can in fact be restarted if re-build for one dimension less.  _slice_type = 'dat'_.
2. _.csv_ files which write comma-separated value ASCII data. _slice_type = 'csv'_
3. _.vtu_ files which directly output the slice transformed to Cartesian coordinates using the calc_grid subroutine. _slice_type = 'vtu'_.  This is the default.  

The different types are provided in the filelist namelist:

     & filelist
            slice_type = 'vtu'
    /

The output filename is composed of the direction
and offset values. For example, the first slice output name reads
_filenameout-d1-x.600-nXXXX.dat_ and analoge for the other two slices.
Note, that the order of the (reduced) dimensions in the resulting output files
is preserved, e.g. the third slice in the example above will hold the
x-direction as first coordinate and the z-direction as second coordinate. This
should be kept in mind for setting up the par file for the convert-step and
also for subsequent visualization.

## Slicing of existing output

To slice existing _*.dat_ files, the simulation can be restarted from a given
output time and the code can be brought to a halt after zero iterations. This
is done in the following way: its best to create a new _*.par_ file (e.g.
slices.par) and clear the savelist from any output to filetypes other than
_3_. We use itsave to demand a slice output for the zero-iteration.

     &savelist;
            itsave(1,3)=0
            nslices=3
            slicedir(1)=1
            slicecoord(1)=0.6
            slicedir(2)=3
            slicecoord(2)=0.8
            slicedir(3)=2
            slicecoord(3)=0.7
    /

The stoplist should look like the following,

     &stoplist;
            itreset=.true.
            itmax=0
    /

where we reset the iteration counter (so that _itsave(1,3)=0_ will output
slice data) and stop the code immediately after the IO (_itmax=0_).

The code can then be started with

    amrvac -restart 10 -i slices.par -slice 10 -if datamr/data

which will take the output _datamr/data0010.dat_ (-restart 10, -if
datamr/data) to create new slices with index 10 (-slice 10). The par-file is
the newly created slices.par (-i slices.par) so that the default used to run
the code can be left untouched. It is a simple exercise in shell scripting to
run along all output-files in one go. For example with the BASH:

    for i in {0..10}; do ./amrvac -restart $i -i slices.par -slice $i -if datamr/data; done