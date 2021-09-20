% Setups GAMSTransfer
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

function gams_transfer_setup(varargin)

    current_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(current_dir, 'src'));

    p = inputParser();
    is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
        ~strcmpi(x, 'target_dir') && ~strcmpi(x, 'gams_dir');
    addParameter(p, 'target_dir', '.', is_string_char);
    addParameter(p, 'gams_dir', find_gams(), is_string_char);
    addParameter(p, 'verbose', 0, @isnumeric)
    parse(p, varargin{:});
    if strcmp(p.Results.gams_dir, '')
        error('GAMS system directory not found.');
    end

    % check paths
    target_dir = Utils.checkFilename(p.Results.target_dir, '', false);
    gams_dir = Utils.checkFilename(p.Results.gams_dir, '', false);

    % get package name
    target_dir = fullfile(target_dir, '+GAMSTransfer');

    % install GAMS Transfer
    try
        gams_transfer_setup_internal(p.Results.gams_dir, current_dir, target_dir, p.Results.verbose)
        rmpath(fullfile(current_dir, 'src'));
    catch e
        rmpath(fullfile(current_dir, 'src'));
        error(e.message);
    end

    fprintf('GAMSTransfer install completed successfully.\n');

end

function gams_transfer_setup_internal(gams_dir, current_dir, target_dir, verbose)

    m_files = dir(fullfile(current_dir, 'src', '*.m'));
    c_files = {
        fullfile(current_dir, 'src', 'gt_gdx_read_basics.c'), ...
        fullfile(current_dir, 'src', 'gt_gdx_read_records.c'), ...
        fullfile(current_dir, 'src', 'gt_gdx_write.c'), ...
        fullfile(current_dir, 'src', 'gt_idx_read_basics.c'), ...
        fullfile(current_dir, 'src', 'gt_idx_read_records.c'), ...
        fullfile(current_dir, 'src', 'gt_idx_write.c'), ...
        fullfile(current_dir, 'src', 'gt_get_defaults.c'), ...
        fullfile(current_dir, 'src', 'gt_getna.c'), ...
        fullfile(current_dir, 'src', 'gt_isna.c'), ...
        fullfile(current_dir, 'src', 'gt_geteps.c'), ...
        fullfile(current_dir, 'src', 'gt_iseps.c'), ...
        fullfile(current_dir, 'src', 'gt_check_sym_order.c'), ...
        fullfile(current_dir, 'src', 'gt_set_sym_domain.c'), ...
    };
    c_common = {
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gdxcc.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'idxcc.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gclgms.c'), ...
        fullfile(current_dir, 'src', 'gt_utils.c'), ...
        fullfile(current_dir, 'src', 'gt_mex.c'), ...
        fullfile(current_dir, 'src', 'gt_gdx_idx.c'), ...
    };
    c_include = {
        fullfile(gams_dir, 'apifiles', 'C', 'api'), ...
    };
    mex_c_flags = {
        '-Wall -DGC_NO_MUTEX' ...
    };
    mex_cpp_flags = {
        '-Wall -DGC_NO_MUTEX' ...
    };
    octmex_c_flags = {
        '-Wall -DGC_NO_MUTEX' ...
    };
    octmex_cpp_flags = {
        '-Wall -DGC_NO_MUTEX' ...
    };
    lib_linux = {
        'dl', ...
    };
    lib_macos = {
        'dl', ...
    };

    % create target directory
    mkdir(target_dir);
    [~, target_folder] = fileparts(target_dir);
    if ~strcmp(target_folder(1), '+')
        warning('Target directory ''%s'' does not create a package.', target_dir);
    end
    fprintf('Package install path: %s\n', target_dir);

    for i = 1:numel(m_files)
        target_file = fullfile(target_dir, m_files(i).name);

        fprintf('Copying (%2d/%2d): %s\n', i, numel(m_files), m_files(i).name);
        copyfile(fullfile(m_files(i).folder, m_files(i).name), target_file);
    end

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
        [~,filename,~] = fileparts(c_files{i});
        target_file = fullfile(target_dir, filename);

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
            if verbose == 0
                cmd = strcat(cmd, ' -silent');
            elseif verbose > 1
                cmd = strcat(cmd, ' -v');
            end

            % output directory
            cmd = sprintf('%s -outdir %s', cmd, target_dir);
        else
            % defined flags
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
            if verbose > 1
                cmd = strcat(cmd, ' -v');
            end

            % output directory
            cmd = sprintf('%s -o %s', cmd, target_file);
        end

        % build
        fprintf('Compiling (%2d/%2d): %s.c\n', i, numel(c_files), filename);
        if verbose >= 1
            fprintf('Command: %s\n', cmd);
        end
        eval(cmd);
    end

end
