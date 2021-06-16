# GAMS Transfer Matlab

GAMSTransfer is a package to maintain GAMS data outside a GAMS script in a
programming language like Python or Matlab. It allows the user to add GAMS
symbols (Sets, Parameters, Variables and Equations), to manipulate GAMS symbols,
read symbols from a GDX file or write them to one. While keeping those
operations as simple as possible for the user, GAMSTransfer’s main focus is the
highly efficient transfer of data between GAMS and the target programming
language. In order to achieve this, symbol records – the actual and potentially
large-scale data sets – are stored in native data structures of the
corresponding programming languages, e.g., dataframes, tables or (sparse)
matrices. The benefits of this approach are threefold: (1) The user is usually
very familiar with these data structures, (2) these data structures come with a
large tool box for various data operations, and (3) optimized methods for
reading from and writing to GDX can transfer the data as a bulk – resulting in
the high performance of this package.

## Install

To build GAMSTransfer, open Matlab and run:
```
gams_transfer_setup('target_dir', <install_directory>, 'system_dir', <gams_system_directory>);
```
The directory `<install_directory>` must start with `+` to create a valid Matlab
package. Both parameters, `target_dir` and `system_dir`, are optional with
defaults `'+GAMSTransfer'` and the GAMS system directory found in the PATH
environment variable, respectively.

## Run Unit Tests

Make sure that the GAMSTransfer build is part of the Matlab PATH. Then, run:
```
gams_transfer_setup('working_dir', <test_directory>, 'system_dir', <gams_system_directory>);
```
Both parameters, `working_dir` and `system_dir`, are optional with defaults
`tempname()` and the GAMS system directory found in the PATH environment
variable, respectively.

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
x.transform('table');

% add equations
cost = Equation(m, 'cost', 'e', 'description', 'define objective function');
supply = Equation(m, 'supply', 'l', i, 'description', 'observe supply limit at plant i');
demand = Equation(m, 'demand', 'g', j, 'description', 'satisfy demand at market j');

% set equation records
% Note: GAMS special value EPS can be inserted with geteps().
cost.setRecords(0, 1, 0, 0);
supply.setRecords(struct('level', [350, 550], 'marginal', [geteps(), 0], 'upper', [350, 600]));
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
         dimension: 2
              size: [2 3]
            domain: {[1×1 GAMSTransfer.Set]  [1×1 GAMSTransfer.Set]}
      domain_label: {'i_1'  'j_2'}
       domain_info: 'regular'
          sparsity: 0
            format: 'table'
    number_records: 6
           records: [6×4 table]
              uels: [1×1 struct]
          is_valid: 1

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
