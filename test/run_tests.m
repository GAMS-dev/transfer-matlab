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

function run_tests(transfer_dir, varargin)

    transfer_dir = gams.transfer.utils.absolute_path(transfer_dir);
    addpath(transfer_dir);

    test_dir = fileparts(mfilename('fullpath'));

    fprintf("Testing %s ...\n", fullfile(transfer_dir, '+gams', '+transfer'));

    p = inputParser();
    is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ~strcmpi(x, 'working_dir');
    addParameter(p, 'working_dir', tempname, is_string_char);
    addParameter(p, 'exit_on_fail', false, @islogical);
    parse(p, varargin{:});

    % check paths
    working_dir = gams.transfer.utils.absolute_path(p.Results.working_dir);

    % create working directory
    mkdir(working_dir);
    filenames = cell(1, 8);
    for i = 1:9
        filenames{i} = fullfile(working_dir, sprintf('data%d.gdx', i));
        copyfile(fullfile(test_dir, 'gdx', sprintf('data%d.gdx', i)), filenames{i});
    end
    olddir = cd(working_dir);

    tic;
    success = true;

    try
        % test data
        cfg = struct();
        cfg.working_dir = working_dir;
        cfg.filenames = filenames;

        % run tests
        success = success & test_general(cfg);
        success = success & test_container(cfg);
        success = success & test_uels(cfg);
        success = success & test_symbols(cfg);
        success = success & test_readwrite(cfg);
        success = success & test_idx_symbols(cfg);
        success = success & test_idx_readwrite(cfg);
        success = success & test_trnsport(cfg);

        cd(olddir);
    catch e
        cd(olddir);
        rethrow(e);
    end

    toc;

    if p.Results.exit_on_fail && ~success
        exit(1);
    end
end
