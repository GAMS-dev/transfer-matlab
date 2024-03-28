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

    files = {
        fullfile(current_dir, '+gdx', 'gt_gdx_read.c'), ...
        fullfile(current_dir, '+gdx', 'gt_gdx_write.c'), ...
        fullfile(current_dir, '+gdx', 'gt_idx_read.c'), ...
        fullfile(current_dir, '+gdx', 'gt_idx_write.c'), ...
        fullfile(current_dir, '+gdx', 'gt_get_defaults.c'), ...
        fullfile(current_dir, '+gdx', 'gt_get_sv.c'), ...
        fullfile(current_dir, '+gdx', 'gt_is_sv.c'), ...
    };

    common_files = {
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'gdxcc.c'), ...
        fullfile(gams_dir, 'apifiles', 'C', 'api', 'idxcc.c'), ...
        fullfile(current_dir, '+gdx', 'gt_utils.c'), ...
        fullfile(current_dir, '+gdx', 'gt_mex.c'), ...
        fullfile(current_dir, '+gdx', 'gt_gdx_idx.c'), ...
    };

    build.system = '';
    if ispc
        build.system = 'windows';
        build.libs = {};
    elseif ismac
        [~,result] = system('uname -v');
        if any(strfind(result, 'ARM64'))
            build.system = 'macos_arm';
        else
            build.system = 'macos';
        end
        build.libs = {'dl'};
    elseif isunix
        build.system = 'linux';
        build.libs = {'dl'};
    end
    build.includes = {
        fullfile(gams_dir, 'apifiles', 'C', 'api'), ...
    };
    build.defines = {
        '-DGC_NO_MUTEX', ...
    };
    build.c_flags = {
        '-Wall', ...
    };
    build.cpp_flags = {
        '-Wall', ...
    };
    build.verbose = p.Results.verbose;
    build.object_path = tempname;

    if build.verbose > 1
        disp(build);
    end

    mkdir(build.object_path);

    try
        fprintf('Compiling %d common files...\n', numel(common_files));
        for i = 1:numel(common_files)
            fprintf('   %d: %s\n', i, common_files{i});
            compile_file(build, common_files{i}, true, {});
        end

        switch build.system
        case {'windows'}
            object_pattern = '*.obj';
        otherwise
            object_pattern = '*.o';
        end
        objects_ = dir(fullfile(build.object_path, object_pattern));
        objects = cell(size(objects_));
        for i = 1:numel(objects_)
            objects{i} = fullfile(objects_(i).folder, objects_(i).name);
        end

        fprintf('Compiling %d main files...\n', numel(files));
        for i = 1:numel(files)
            fprintf('   %d: %s\n', i, files{i});
            compile_file(build, files{i}, false, objects);
        end

        fprintf('GAMS Transfer install completed successfully.\n');
    catch e
        rmdir(build.object_path, 's');
        rethrow(e);
    end

end

function compile_file(build, filename, object_only, other_objects)

    % file in target directory
    [target_filepath, target_filename, target_fileext] = fileparts(filename);

    cmd = sprintf('mex %s', filename);
    for i = 1:numel(other_objects)
        cmd = sprintf('%s %s', cmd, other_objects{i});
    end

    % includes
    for i = 1:numel(build.includes)
        cmd = sprintf('%s -I%s', cmd, build.includes{i});
    end

    % libraries
    for i = 1:numel(build.libs)
        cmd = sprintf('%s -l%s', cmd, build.libs{i});
    end

    % defines
    version_release = regexp(version(), 'R[0-9]{4}[ab]', 'match');
    if ~gams.transfer.Constants.IS_OCTAVE && ~isempty(version_release)
        version_release_year = str2double(version_release{1}(2:5));
        if version_release_year >= 2018
            cmd = sprintf('%s %s', cmd, '-r2018a');
            cmd = sprintf('%s %s', cmd, '-DWITH_R2018A_OR_NEWER');
        end
    end
    for i = 1:numel(build.defines)
        cmd = sprintf('%s %s', cmd, build.defines{i});
    end

    % C/C++ flags
    if ~gams.transfer.Constants.IS_OCTAVE
        switch build.system
        case {'macos', 'macos_arm', 'linux'}
            cmd = strcat(cmd, ' CFLAGS=''$CFLAGS ');
        case {'windows'}
            cmd = strcat(cmd, ' COMPFLAGS=''$COMPFLAGS ');
        otherwise
            error('Unknown system %s', build.system);
        end
    end
    switch target_fileext
    case {'.c', '.C'}
        for i = 1:numel(build.c_flags)
            cmd = sprintf('%s %s', cmd, build.c_flags{i});
        end
    case {'.cpp', '.CPP'}
        for i = 1:numel(build.cpp_flags)
            cmd = sprintf('%s %s', cmd, build.cpp_flags{i});
        end
    end
    if ~gams.transfer.Constants.IS_OCTAVE
        cmd = strcat(cmd, '''');
    end

    % output level
    if build.verbose == 0 && ~gams.transfer.Constants.IS_OCTAVE
        cmd = strcat(cmd, ' -silent');
    elseif build.verbose > 1
        cmd = strcat(cmd, ' -v');
    end

    % output directory
    if gams.transfer.Constants.IS_OCTAVE
        if object_only
            switch build.system
            case {'windows'}
                filename = fullfile(build.object_path, [target_filename, '.obj']);
            otherwise
                filename = fullfile(build.object_path, [target_filename, '.o']);
            end
            cmd = sprintf('%s -c -o %s', cmd, filename);
        else
            cmd = sprintf('%s -o %s', cmd, fullfile(target_filepath, target_filename));
        end
    else
        if object_only
            cmd = sprintf('%s -c -outdir %s', cmd, build.object_path);
        else
            cmd = sprintf('%s -outdir %s', cmd, target_filepath);
        end
    end

    % build
    if build.verbose >= 1
        fprintf('Command: %s\n', cmd);
    end
    eval(cmd);
end
