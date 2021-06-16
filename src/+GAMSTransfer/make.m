% Builds GAMSTransfer C interface
%

%
% GAMS - General Algebraic Modeling System Matlab API
%
% Copyright (c) 2020-2021 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2021 GAMS Development Corp. <support@gams.com>
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

function make()

    gams_dir = GAMSTransfer.find_gams();

    c_files = {
        fullfile('+GAMSTransfer', 'gt_gdx_read_basics.c'), ...
        fullfile('+GAMSTransfer', 'gt_gdx_read_records.cpp'), ...
        fullfile('+GAMSTransfer', 'gt_gdx_write.c'), ...
        fullfile('+GAMSTransfer', 'gt_idx_read_basics.c'), ...
        fullfile('+GAMSTransfer', 'gt_idx_read_records.c'), ...
        fullfile('+GAMSTransfer', 'gt_idx_write.c'), ...
        fullfile('+GAMSTransfer', 'gt_get_defaults.c'), ...
        fullfile('+GAMSTransfer', 'getna.c'), ...
        fullfile('+GAMSTransfer', 'isna.c'), ...
        fullfile('+GAMSTransfer', 'geteps.c'), ...
        fullfile('+GAMSTransfer', 'iseps.c'), ...
    };
    c_common = {
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gdxcc.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'idxcc.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gclgms.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gcmt.c'), ...
        fullfile('+GAMSTransfer', 'gt_utils.c'), ...
        fullfile('+GAMSTransfer', 'gt_mex.c'), ...
        fullfile('+GAMSTransfer', 'gt_gdx_idx.c'), ...
    };
    c_include = {
        fullfile(gams_dir, 'apifiles', 'C', 'api'), ...
    };
    mex_c_flags = {
        '-silent -g COMPFLAGS=''$COMPFLAGS -Wall''' ...
    };
    mex_cpp_flags = {
        '-silent -g COMPFLAGS=''$COMPFLAGS -Wall''' ...
    };
    lib_linux = {
        'dl', ...
    };
    lib_macos = {
        'dl', ...
    };


    for i = 1:numel(c_files)

        % create build command
        cmd = sprintf('mex %s', c_files{i});
        for e = c_common
            cmd = sprintf('%s %s', cmd, e{1});
        end
        for e = c_include
            cmd = sprintf('%s -I%s', cmd, e{1});
        end

        if ismac
            for e = lib_macos
                cmd = sprintf('%s -l%s', cmd, e{1});
            end
        elseif isunix
            for e = lib_linux
                cmd = sprintf('%s -l%s', cmd, e{1});
            end
        elseif ispc
        end

        % check octave / matlab version
        if exist('OCTAVE_VERSION', 'builtin') <= 0
            % Matlab version flags
            v_release = regexp(version(), 'R[0-9]{4}[ab]', 'match');
            if ~isempty(v_release)
                v_release_year = str2double(v_release{1}(2:5));
                if v_release_year >= 2018
                    cmd = sprintf('%s %s', cmd, '-r2018a');
                    cmd = sprintf('%s %s', cmd, '-DWITH_R2018A_OR_NEWER');
                end
            end

            % defined flags
            [~,~,ext] = fileparts(c_files{i});
            if strcmp(ext, '.c')
                for e = mex_c_flags
                    cmd = sprintf('%s %s', cmd, e{1});
                end
            elseif strcmp(ext, '.cpp')
                for e = mex_cpp_flags
                    cmd = sprintf('%s %s', cmd, e{1});
                end
            end

            % output directory
            cmd = sprintf('%s -outdir +GAMSTransfer', cmd);
        else
            % output directory
            [filepath,filename,~] = fileparts(c_files{i});
            cmd = sprintf('%s -o %s', cmd, fullfile(filepath, filename));
        end

        % build
        fprintf('Compiling (%2d/%2d): %s\n', i, numel(c_files), c_files{i});
        eval(cmd);
    end

    fprintf('GAMSTransfer install completed successfully.\n');

end
