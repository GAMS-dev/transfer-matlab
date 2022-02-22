
[![pipeline status](https://git.gams.com/devel/gams-transfer-matlab/badges/master/pipeline.svg)](https://git.gams.com/devel/gams-transfer-matlab/-/commits/master) 

# GAMS Transfer Matlab

GAMS Transfer is a package to maintain GAMS data outside a GAMS script in a
programming language like Python or Matlab. It allows the user to add GAMS
symbols (Sets, Parameters, Variables and Equations), to manipulate GAMS symbols,
read symbols from a GDX file or write them to one. While keeping those
operations as simple as possible for the user, GAMS Transfer’s main focus is the
highly efficient transfer of data between GAMS and the target programming
language. In order to achieve this, symbol records – the actual and potentially
large-scale data sets – are stored in native data structures of the
corresponding programming languages, e.g., dataframes, tables or (sparse)
matrices. The benefits of this approach are threefold: (1) The user is usually
very familiar with these data structures, (2) these data structures come with a
large tool box for various data operations, and (3) optimized methods for
reading from and writing to GDX can transfer the data as a bulk – resulting in
the high performance of this package.

## Documentation

See [GAMS Transfer Matlab Tutorial](https://www.gams.com/37/docs/API_MATLAB_GAMSTRANSFER_TUTORIAL.html).

## Install

Note, GAMS comes with a precompiled GAMS Transfer Matlab version. For custom or 
Octave builds, follow the steps below.

To build GAMSTransfer, open Matlab and run `gams_transfer_setup`:
```matlab
gams_transfer_setup()
gams_transfer_setup(_, 'target_dir', <install_directory>)
gams_transfer_setup(_, 'gams_dir', <gams_gams_dir>)
gams_transfer_setup(_, 'verbose', <level>)
```
Description of parameters:
- `target_dir`: Installation directory. Default: `'.'`.
- `gams_dir`: GAMS system directory. Default: found from PATH environment variable.
- `verbose`: Compilation verbosity level from 0 (no compiler output) to 2 (all 
  compiler output). Default: 0.

Add the GAMS Transfer installtion directory to the Matlab Path: 
```matlab
addpath(<install_directory>)
```

## Run Unit Tests

Make sure that the GAMSTransfer build is part of the Matlab PATH. Then, run
`gams_transfer_test`:
```matlab
gams_transfer_test()
gams_transfer_test(_, 'working_dir', <test_directory>)
gams_transfer_test(_, 'gams_dir', <gams_gams_dir>)
```
Description of parameters:
- `working_dir`: Directory for test example GAMS / GDX files. Default: `tempname()`.
- `gams_dir`: GAMS system directory. Default: found from PATH environment variable.

## Example

The following example creates a GDX file that could also be generated with `gams
trnsport GDX=trnsport.gdx`.
```matlab
import GAMSTransfer.*

% create an empty container
m = Container();

% add sets
i = Set(m, 'i', 'records', {'seattle', 'san-diego'}, 'description', 'canning plants');
j = Set(m, 'j', 'records', {'new-york', 'chicago', 'topeka'}, 'description', 'markets');

% add parameters
a = Parameter(m, 'a', i, 'description', 'capacity of plant i in cases');
b = Parameter(m, 'b', j, 'description', 'demand at market j in cases');
d = Parameter(m, 'd', {i,j}, 'description', 'distance in thousands of miles');
f = Parameter(m, 'f', 'description', 'freight in dollars per case per thousand miles');
c = Parameter(m, 'c', {i,j}, 'description', 'transport cost in thousands of dollars per case');

% set parameter records
a.setRecords([350, 600]);
b.setRecords([325, 300, 275]);
d.setRecords([2.5, 1.7, 1.8; 2.5, 1.8, 1.4]);
f.setRecords(90);
c.setRecords([0.225, 0.153, 0.162; 0.225, 0.162, 0.126]);

% add variables
x = Variable(m, 'x', 'positive', {i,j}, 'description', 'shipment quantities in cases');
z = Variable(m, 'z', 'description', 'total transportation costs in thousands of dollars');

% set variable records
% Note: Argument order is: level, marginal, lower, upper, scale.
x.setRecords([50, 300, 0; 275, 0, 275], [0, 0, 0.036; 0, 0.009, 0]);
z.setRecords(153.675);

% (optional) transform records into different format
x.transformRecords('table');

% add equations
cost = Equation(m, 'cost', 'e', 'description', 'define objective function');
supply = Equation(m, 'supply', 'l', i, 'description', 'observe supply limit at plant i');
demand = Equation(m, 'demand', 'g', j, 'description', 'satisfy demand at market j');

% set equation records
cost.setRecords(0, 1, 0, 0);
supply.setRecords(struct('level', [350, 550], 'marginal', [SpecialValues.EPS, 0], 'upper', [350, 600]));
demand.setRecords([325, 300, 275], [0.225, 0.153, 0.126], [325, 300, 275]);

% write data to a GDX file
m.write('trnsport.gdx');
```

A GAMSTransfer symbol looks like:
```matlab
>> x

x =

  Variable with properties:

              name: 'x'
       description: 'shipment quantities in cases'
              type: 'positive'
    default_values: [1×1 struct]
         dimension: 2
              size: [2 3]
            domain: {[1×1 GAMSTransfer.Set]  [1×1 GAMSTransfer.Set]}
      domain_names: {'i'  'j'}
     domain_labels: {'i_1'  'j_2'}
       domain_type: 'regular'
           records: [6×4 table]
            format: 'table'

>> x.records

ans =

  6×4 table

       i_1         j_2       level    marginal
    _________    ________    _____    ________

    seattle      new-york      50          0
    seattle      chicago      300          0
    seattle      topeka         0      0.036
    san-diego    new-york     275          0
    san-diego    chicago        0      0.009
    san-diego    topeka       275          0
```
