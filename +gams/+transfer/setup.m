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
%
% Required Arguments:
% 1. gdx_path (string):
%    Path to GDX repository. Use submodule in ext/gdx or clone https://github.com/GAMS-dev/gdx.
% 2. idx_path (string):
%    Path to IDX API. Use ext/idx or [GAMS]/apifiles/C/api
% 3. zlib_path (string):
%    Path zo ZLIB repository. Use submodule in ext/zlib or clone https://github.com/madler/zlib.
function setup(varargin)

    current_dir = fileparts(mfilename('fullpath'));

    p = inputParser();
    is_string_char = @(x) (isstring(x) && isscalar(x) || ischar(x));
    addRequired(p, 'gdx_path', is_string_char);
    addRequired(p, 'zlib_path', is_string_char);
    addParameter(p, 'verbose', 0, @isnumeric);
    parse(p, varargin{:});

    fprintf('Using GDX path: %s\n', p.Results.gdx_path);
    fprintf('Using ZLIB path: %s\n', p.Results.zlib_path);

    % MEX files
    files = {
        fullfile(current_dir, '+gdx', 'gt_gdx_read.cpp'), ...
        fullfile(current_dir, '+gdx', 'gt_gdx_write.cpp'), ...
        fullfile(current_dir, '+gdx', 'gt_idx_read.cpp'), ...
        fullfile(current_dir, '+gdx', 'gt_idx_write.cpp'), ...
        fullfile(current_dir, '+gdx', 'gt_get_defaults.c'), ...
        fullfile(current_dir, '+gdx', 'gt_get_sv.c'), ...
        fullfile(current_dir, '+gdx', 'gt_is_sv.c'), ...
    };
    use_gdx = false(1, numel(files));
    use_gdx(1:4) = true;
    use_zlib = false(1, numel(files));
    use_zlib(1:4) = true;

    % Common C/C++ files
    common_files = {
        fullfile(current_dir, '+gdx', 'gt_utils.c'), ...
        fullfile(current_dir, '+gdx', 'gt_mex.c'), ...
    };

    % GDX files
    filelist = {
        dir(fullfile(p.Results.gdx_path, 'src', '*.cpp')), ...
        dir(fullfile(p.Results.gdx_path, 'src', 'gdlib', '*.cpp')), ...
        dir(fullfile(p.Results.gdx_path, 'src', 'rtl', '*.cpp')), ...
        dir(fullfile(p.Results.gdx_path, 'src', 'rtl', '*.c')), ...
        dir(fullfile(p.Results.gdx_path, 'src', 'global', '*.cpp')), ...
    };
    gdx_files = cell(1, numel(filelist));
    for i = 1:numel(filelist)
        gdx_files{i} = cell(1, numel(filelist{i}));
        for j = 1:numel(filelist{i})
            gdx_files{i}{j} = fullfile(filelist{i}(j).folder, filelist{i}(j).name);
        end
    end
    gdx_files = horzcat(gdx_files{:}, {
        fullfile(current_dir, '+gdx', 'gt_idx.cpp'), ...
        fullfile(current_dir, '+gdx', 'gt_gdx_idx.cpp'), ...
    });

    % ZLIB files
    filelist = {
        dir(fullfile(p.Results.zlib_path, '*.c')), ...
    };
    zlib_files = cell(1, numel(filelist));
    for i = 1:numel(filelist)
        zlib_files{i} = cell(1, numel(filelist{i}));
        for j = 1:numel(filelist{i})
            zlib_files{i}{j} = fullfile(filelist{i}(j).folder, filelist{i}(j).name);
        end
    end
    zlib_files = horzcat(zlib_files{:});

    % Build properties
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
        build.libs = {'dl', 'pthread'};
    elseif isunix
        build.system = 'linux';
        build.libs = {'dl', 'pthread'};
    end
    build.includes = {
        fullfile(p.Results.gdx_path, 'generated'), ...
        fullfile(p.Results.gdx_path, 'src'), ...
        fullfile(p.Results.gdx_path, 'src', 'gdlib'), ...
        fullfile(p.Results.zlib_path), ...
    };
    build.defines = {
        '-DGC_NO_MUTEX', ...
        '-DHAS_GDX_SOURCE', ...
    };
    switch build.system
    case {'macos', 'macos_arm'}
        build.defines{end+1} = '-DZ_HAVE_UNISTD_H';
    end
    build.c_flags = {
        '-Wall', ...
        '-Wno-unused-variable', ...
        '-Wno-stringop-truncation', ...
    };
    build.cpp_flags = {
        '-Wall', ...
        '-Wno-unused-variable', ...
        '-Wno-stringop-truncation', ...
        '-std=c++17', ...
    };
    build.cpp_comp_flags = {
        '/std:c++17', ...
    };
    build.verbose = p.Results.verbose;
    build.object_path = tempname;
    if build.verbose > 1
        disp(build);
    end

    mkdir(build.object_path);

    try
        fprintf('Compiling %d common files...\n', numel(common_files));
        build_common = build;
        for i = 1:numel(common_files)
            fprintf('   %d: %s\n', i, common_files{i});
            compile_file(build_common, common_files{i}, true, {});
        end
        common_objects = find_objects(build);

        fprintf('Compiling %d GDX files...\n', numel(gdx_files));
        build_gdx = build;
        build_gdx.object_path = fullfile(build.object_path, 'gdx');
        mkdir(build_gdx.object_path);
        for i = 1:numel(gdx_files)
            fprintf('   %d: %s\n', i, gdx_files{i});
            compile_file(build_gdx, gdx_files{i}, true, {});
        end
        gdx_objects = find_objects(build_gdx);

        fprintf('Compiling %d ZLIB files...\n', numel(zlib_files));
        build_zlib = build;
        build_zlib.object_path = fullfile(build.object_path, 'zlib');
        mkdir(build_zlib.object_path);
        for i = 1:numel(zlib_files)
            fprintf('   %d: %s\n', i, zlib_files{i});
            compile_file(build_zlib, zlib_files{i}, true, {});
        end
        zlib_objects = find_objects(build_zlib);

        fprintf('Compiling %d main files...\n', numel(files));
        for i = 1:numel(files)
            fprintf('   %d: %s\n', i, files{i});
            objects = common_objects;
            if use_gdx(i)
                objects = vertcat(objects, gdx_objects); %#ok<AGROW>
            end
            if use_zlib(i)
                objects = vertcat(objects, zlib_objects); %#ok<AGROW>
            end
            compile_file(build, files{i}, false, objects);
        end

        rmdir(build.object_path, 's');

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
    switch target_fileext
    case {'.c', '.C'}
        if ~gams.transfer.Constants.IS_OCTAVE
            cmd = strcat(cmd, ' CFLAGS=''$CFLAGS ');
        end
        for i = 1:numel(build.c_flags)
            cmd = sprintf('%s %s', cmd, build.c_flags{i});
        end
        if ~gams.transfer.Constants.IS_OCTAVE
            cmd = strcat(cmd, '''');
        end
    case {'.cpp', '.CPP'}
        if ~gams.transfer.Constants.IS_OCTAVE
            if strcmp(build.system, 'windows')
                cmd = strcat(cmd, ' COMPFLAGS=''$COMPFLAGS ');
                for i = 1:numel(build.cpp_comp_flags)
                    cmd = sprintf('%s %s', cmd, build.cpp_comp_flags{i});
                end
                cmd = strcat(cmd, '''');

            end
            cmd = strcat(cmd, ' CXXFLAGS=''$CXXFLAGS ');
        end
        for i = 1:numel(build.cpp_flags)
            cmd = sprintf('%s %s', cmd, build.cpp_flags{i});
        end
        if ~gams.transfer.Constants.IS_OCTAVE
            cmd = strcat(cmd, '''');
        end
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

function objects = find_objects(build)
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
end
