% GAMS Transfer Setup
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
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
% ------------------------------------------------------------------------------
%
% GAMS Transfer Setup
function setup(varargin)

    current_dir = fileparts(mfilename('fullpath'));

    p = inputParser();
    is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x));
    addParameter(p, 'verbose', 0, @isnumeric)
    addParameter(p, 'gams_dir', '', is_string_char);
    parse(p, varargin{:});
    if strcmp(p.Results.gams_dir, '')
        gams_dir = gams.transfer.utils.absolute_path(gams.transfer.utils.find_gdx());
    else
        gams_dir = gams.transfer.utils.absolute_path(p.Results.gams_dir);
    end

    c_files = {
        fullfile(current_dir, '+gdx', 'gt_gdx_read.c'), ...
        fullfile(current_dir, '+gdx', 'gt_gdx_write.c'), ...
        fullfile(current_dir, '+gdx', 'gt_idx_read.c'), ...
        fullfile(current_dir, '+gdx', 'gt_idx_write.c'), ...
        fullfile(current_dir, '+gdx', 'gt_get_defaults.c'), ...
        fullfile(current_dir, '+gdx', 'gt_get_sv.c'), ...
        fullfile(current_dir, '+gdx', 'gt_is_sv.c'), ...
    };
    c_common = {
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gdxcc.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'idxcc.c'), ...
        fullfile(current_dir, '+gdx', 'gt_utils.c'), ...
        fullfile(current_dir, '+gdx', 'gt_mex.c'), ...
        fullfile(current_dir, '+gdx', 'gt_gdx_idx.c'), ...
    };
    c_include = {
        fullfile(gams_dir, 'apifiles', 'C', 'api'), ...
    };
    defines = {
        '-DGC_NO_MUTEX', ...
    };
    mex_c_flags = {
        '-Wall', ...
    };
    mex_cpp_flags = {
        '-Wall', ...
    };
    octmex_c_flags = {
        '-Wall', ...
    };
    octmex_cpp_flags = {
        '-Wall', ...
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

        % filename in target directory
        [target_path, filename, ~] = fileparts(c_files{i});
        target_file = fullfile(target_path, filename);

        % check octave / matlab version
        if ~gams.transfer.Constants.IS_OCTAVE
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
            for e = defines
                cmd = sprintf('%s %s', cmd, e{1});
            end
            if ismac || isunix
                cmd = strcat(cmd, ' CFLAGS=''$CFLAGS ');
            else
                cmd = strcat(cmd, ' COMPFLAGS=''$COMPFLAGS ');
            end
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
            cmd = strcat(cmd, '''');

            % output level
            if p.Results.verbose == 0
                cmd = strcat(cmd, ' -silent');
            elseif p.Results.verbose > 1
                cmd = strcat(cmd, ' -v');
            end

            % output directory
            cmd = sprintf('%s -outdir %s', cmd, target_path);
        else
            % defined flags
            for e = defines
                cmd = sprintf('%s %s', cmd, e{1});
            end
            [~,~,ext] = fileparts(c_files{i});
            if strcmp(ext, '.c')
                for e = octmex_c_flags
                    cmd = sprintf('%s %s', cmd, e{1});
                end
            elseif strcmp(ext, '.cpp')
                for e = octmex_cpp_flags
                    cmd = sprintf('%s %s', cmd, e{1});
                end
            end

            % output level
            if p.Results.verbose > 1
                cmd = strcat(cmd, ' -v');
            end

            % output directory
            cmd = sprintf('%s -o %s', cmd, target_file);
        end

        % build
        fprintf('Compiling (%2d/%2d): %s.c\n', i, numel(c_files), filename);
        if p.Results.verbose >= 1
            fprintf('Command: %s\n', cmd);
        end
        eval(cmd);
    end

    fprintf('GAMS Transfer install completed successfully.\n');

end
