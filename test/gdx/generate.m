% Tests GAMS Transfer
%

%
% GAMS - General Algebraic Modeling System Matlab API
%
% Copyright (c) 2020-2024 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2024 GAMS Development Corp. <support@gams.com>
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the 'Software'), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%

function gams_transfer_testcreate(varargin)

    current_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(current_dir, '..', '..', 'test'));
    addpath(fullfile(current_dir, '..', '..', 'src'));

    p = inputParser();
    is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
        ~strcmpi(x, 'gams_dir');
    addParameter(p, 'gams_dir', find_gams(), is_string_char);
    addParameter(p, 'license', '', is_string_char);
    parse(p, varargin{:});
    if strcmp(p.Results.gams_dir, '')
        error('GAMS system directory not found.');
    end

    % check paths
    gams_dir = gams.transfer.utils.absolute_path(p.Results.gams_dir);
    working_dir = tempname;

    mkdir(working_dir);
    olddir = cd(working_dir);

    n_probs = 9;
    gams_data = cell(1, n_probs);
    gdx_filenames = cell(1, n_probs);

    gams_data{1} = {
    'Set i ''set_i'' / i1, i3 ''expl text 3'', i4, i6, i10 ''expl text 10''/;'
    'Set j ''set_j'' / j2, j5 ''expl text 5'', j7 ''expl text 7'', j8 ''expl text 8'', j9 /;'
    'Scalar a ''par_a'' / 4 /;'
    'Parameter b(i) ''par_b'' / i1=1, i3=3, i10=10 /;'
    'Positive Variable x(i,j) ''var_x'';'
    'x.l(''i1'',''j2'') = 2; x.l(''i10'',''j7'') = 7; x.l(''i3'',''j9'') = 9;'
    'x.up(''i6'',''j7'') = 30;'
    'x.m(''i3'',''j8'') = 8; x.m(''i6'',''j5'') = 5;'
    'execute_unloaddi ''data1.gdx'', i, j, a, b, x;'
    };

    gams_data{2} = {
    'Scalar GUndef;'
    'Scalar GNA / NA /;'
    'Scalar GPInf / +Inf /;'
    'Scalar GMInf / -Inf /;'
    'Scalar GEps / eps /;'
    'GUndef = 1/0;'
    'ExecError = 0;'
    'execute_unloaddi ''data2.gdx'', GUndef, GNA, GPInf, GMInf, GEps;'
    };

    gams_data{3} = {
    'Set i / 1*10 /;'
    'Set j / 1*2 /;'
    'Alias(i,i2);'
    'Alias(j,j2);'
    'Parameter a(j) / 1=3, 2=4 /;'
    'Variable x1(j);'
    'Free Variable x2(j);'
    'Binary Variable x3(j);'
    'Integer Variable x4(j);'
    'Positive Variable x5(j);'
    'Negative Variable x6(j);'
    'SOS1 Variable x7(j,i);'
    'SOS2 Variable x8(j,i);'
    'SemiInt Variable x9(j);'
    'SemiCont Variable x10(j);'
    'Variable x11(*);'
    'x1.l(''1'') = 1;'
    'x2.l(''1'') = 1;'
    'x3.l(''1'') = 1;'
    'x4.l(''1'') = 1;'
    'x5.l(''1'') = 1;'
    'x6.l(''1'') = -1;'
    'x7.l(''1'',i) = 1;'
    'x8.l(''1'',i) = 1;'
    'x9.l(''1'') = 1;'
    'x10.l(''1'') = 1;'
    'Equation e1(j) ''equ_1'';'
    'Equation e2(j) ''equ_2'';'
    'Equation e3(j) ''equ_3'';'
    'e1(''1'').. x1(''1'') =e= 1;'
    'e2(''1'').. x2(''1'') =g= 1;'
    'e3(''1'').. x3(''1'') =l= 1;'
    'execute_unloaddi ''data3.gdx'', i, j, i2, j2, a, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, e1, e2, e3;'
    };

    gams_data{4} = {
    'Set i ''set_i'' / 1*5 /;'
    'Set j ''set_j'' / 1*10 /;'
    'Scalar a ''par_a'' / 4 /;'
    'Parameter b(i) ''par_b'' / 1=1, 3=3, 5=5 /;'
    'Parameter c(i,j) ''par_c'' / 1.6=16, 3.7=37, 4.9=49 /;'
    'execute_unloadidx ''data4.gdx'', a, b, c;'
    };

    gams_data{5} = {
    'Set i ''set_i'' / i1 ''i_elem_1'', i2, i3 ''i_elem_3'', i4, i5 ''i_elem_5'' /;'
    'execute_unloaddi ''data5.gdx'', i;'
    };

    gams_data{6} = {
    'Set i / i1 * i3 /;'
    'Acronym small ''baby bear'', medium ''mama bear'', large ''papa bear'';'
    'Parameter a(i) / i1 1, i2 medium, i3 large /;'
    'execute_unloaddi ''data6.gdx'', i, a;'
    };

    gams_data{7} = {
    'Set i ''set_i'' / i1, i2 /;'
    'Alias (a,i);'
    'Alias (u,*);'
    'Parameter b(a) ''par_b'' / i1=1, i2=2 /;'
    'execute_unloaddi ''data7.gdx'', i, a, u, b;'
    };

    gams_data{8} = {
    'Set i(i) ''set_i'' / i1, i2 /;'
    'Parameter a(i) ''par_a'' / i1=1, i2=2 /;'
    'execute_unloaddi ''data8.gdx'', i, a;'
    };

    gams_data{9} = {
    'Set i ''set_i'' / i1*i10/;'
    'Set j ''set_j'' / j1*j10/;'
    'Set k ''set_k'' / k1*k10/;'
    'Parameter a(i,i) ''par_a'';'
    'Parameter b(i,j) ''par_b'';'
    'Parameter c(i,j,i) ''par_c'';'
    'Parameter d(i,j,k) ''par_d'';'
    'execute_unloaddi ''data9.gdx'', i, j, k, a, b, c, d;'
    };

    for i = 1:n_probs
        gams_exe = fullfile(gams_dir, 'gams');
        gms_filename = fullfile(working_dir, sprintf('data%d.gms', i));
        gdx_filenames{i} = fullfile(working_dir, sprintf('data%d.gdx', i));

        % create GMS file
        fid = fopen(gms_filename, 'w');
        if fid < 0
            error('Can''t write file: %s', gms_filename);
        end
        for j = 1:numel(gams_data{i})
            fprintf(fid, '%s\n', gams_data{i}{j});
        end
        fclose(fid);

        % create GDX file
        cmd = [gams_exe, ' ', gms_filename];
        if ~isempty(p.Results.license)
            cmd = sprintf('%s license=%s', cmd, p.Results.license);
        end
        [rc, stdout] = system(cmd);
        if rc
            disp(stdout);
            error('Can''t create GAMS test files.');
        end

        % copy GDX file into repository
        copyfile(gdx_filenames{i}, fullfile(current_dir, sprintf('data%d.gdx', i)));
    end

    cd(olddir)

end
