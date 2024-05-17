
# GAMS Transfer Matlab

[GAMS]: https://www.gams.com/
[GDX]: https://github.com/GAMS-dev/gdx

GAMS Transfer is a package to maintain [GAMS] data outside a [GAMS] script in a programming language
like Python or Matlab. It allows the user to add [GAMS] symbols (Sets, Parameters, Variables and
Equations), to manipulate [GAMS] symbols, read symbols from a [GDX] file or write them to one. While
keeping those operations as simple as possible for the user, GAMS Transfer's main focus is the
highly efficient transfer of data between GAMS and the target programming language. In order to
achieve this, symbol records – the actual and potentially large-scale data sets – are stored in
native data structures of the corresponding programming languages, e.g., dataframes, tables or
(sparse) matrices. The benefits of this approach are threefold:
- The user is usually very familiar with these data structures.
- These data structures come with a large tool box for various data operations.
- Optimized methods for reading from and writing to [GDX] can transfer the data as a bulk –-
  resulting in the high performance of this package.

## Install

Note: Releases come with built artifacts that are ready to use so usually compiling is not necessary.

Requires Matlab 2018a (or newer) or Octave with C/C++ compilers.

To build GAMS Transfer Matlab from source, open Matlab, move into the GAMS Transfer Matlab directory
and run:
```matlab
gams.transfer.setup('ext/gdx', 'ext/zlib')
```
Make sure, that the submodules `gdx` and `zlib` in `ext` are checked out (`git submodule update
--init`).

## Usage

Simply add the GAMS Transfer Matlab root directory (the one that has a `+gams` directory) to the
Matlab path:
```
addpath('.')
```

Note that GAMS Transfer Matlab comes as a Matlab package and, thus, all classes must be prefixed
with `gams.transfer.`. In order to avoid this, you can import the package with:
```
import gams.transfer.*
```

## Tests

Run:
```matlab
addpath('test');
run_tests('.')
run_tests(_, 'working_dir', <test_directory>)
```
Description of parameters:
- `working_dir`: Directory for test example GAMS / GDX files. Default: `tempname()`.

## Example

We consider creating a GDX file in Matlab with content equal to the solution
data of model
[trnsport](https://www.gams.com/latest/gamslib_ml/libhtml/gamslib_trnsport.html).

### Create with GAMS:
```matlab
gamslib trnsport
gams trnsport GDX=trnsport.gdx
```

### Create with Matlab:
```matlab
import gams.transfer.*

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

```
>> x

x =

  Variable with properties:

                 name: 'x'
          description: 'shipment quantities in cases'
                 type: 'positive'
       default_values: [1×1 struct]
            dimension: 2
                 size: [2 3]
               domain: {[1×1 gams.transfer.symbol.Set]  [1×1 gams.transfer.symbol.Set]}
         domain_names: {'i'  'j'}
        domain_labels: {'i'  'j'}
          domain_type: 'regular'
    domain_forwarding: 0
              records: [6×4 table]
               format: 'table'

>> x.records

ans =

  6×4 table

        i           j        level    marginal
    _________    ________    _____    ________

    seattle      new-york      50          0
    seattle      chicago      300          0
    seattle      topeka         0      0.036
    san-diego    new-york     275          0
    san-diego    chicago        0      0.009
    san-diego    topeka       275          0
```
