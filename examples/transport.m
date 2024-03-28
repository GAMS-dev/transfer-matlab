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
