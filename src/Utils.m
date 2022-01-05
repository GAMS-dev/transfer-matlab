classdef Utils
    % GAMSTransfer Utilities
    %
    % Collection of utility functions used by GAMSTransfer
    %

    %
    % GAMS - General Algebraic Modeling System Matlab API
    %
    % Copyright (c) 2020-2022 GAMS Software GmbH <support@gams.com>
    % Copyright (c) 2020-2022 GAMS Development Corp. <support@gams.com>
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

    methods (Static)

        function feature_support = checkFeatureSupport()
            % Checks support of different Matlab features
            %
            % s = Utils.checkFeatureSupport() returns a struct of boolean fields
            % indicating which feature is supported by the current Matlab/Octave
            % environment. The fields of s are:
            % - categorical:       categorical arrays
            % - table:             data type table
            % - c_prop_setget:     calling set/get methods when querying data from c
            %
            % Note that a latest Matlab version should return true for all
            % fields.
            %

            feature_support = struct('categorical', true, 'table', true, 'c_prop_setget', true);

            if exist('OCTAVE_VERSION', 'builtin') > 0
                feature_support.categorical = false;
                feature_support.table = false;
                feature_support.c_prop_setget = false;
                v_release = strsplit(version(), '.');
                for i = 1:3
                    v_release{i} = str2double(v_release{i});
                end
            else
                v_release = regexp(version(), 'R[0-9]{4}[ab]', 'match');
                if ~isempty(v_release)
                    v_release_year = str2double(v_release{1}(2:5));
                    v_release_ab = v_release{1}(6);
                    if v_release_year < 2015
                        feature_support.categorical = false;
                    end
                    if v_release_year < 2013 || (v_release_year == 2013 && strcmp(v_release_ab, 'a'))
                        feature_support.table = false;
                    end
                end
            end
        end

        function gams_dir = checkGamsDirectory(gams_dir)
            % Checks if given path is a valid GAMS system directory
            %
            % Utils.checkGamsDirectory(d) returns the given system
            % directory, finds a system directory if none is given or raises an
            % error if the given system directory is invalid.
            %

            if ispc
                gams_exe = 'gams.exe';
            else
                gams_exe = 'gams';
            end
            if strcmp(gams_dir, '')
                gams_dir = GAMSTransfer.find_gams();
            end
            if ~isfile(fullfile(gams_dir, gams_exe))
                error('Invalid GAMS system directory: %s', gams_dir);
            end
        end

        function filename = checkFilename(filename, extension, check_exists)
            % Validates a file name
            %
            % f = Utils.checkFilename(f, ext, e) checks a file name (or path)
            % for a correct extension ext. If e is true, it also checks if the
            % file is available. The returned filename is a canonical path to
            % the file.
            %

            if strcmp(filename, '')
                return
            end

            % replace ~ with home directory in path
            if ispc
                homedir = fullfile(getenv('HOMEDRIVE'), getenv('HOMEPATH'));
            else
                homedir = getenv('HOME');
            end
            filename = regexprep(filename, '^~', strrep(homedir, '\', '\\'));

            [filepath, ~, fileext] = fileparts(filename);

            % check file extension and if file exists
            if ~isempty(extension) && ~strcmpi(fileext, extension)
                error('Invalid file extension: %s instead of %s', fileext, extension);
            end
            if check_exists && ~isfile(filename)
                error('File does not exist: %s', filename);
            end

            % get absolute path of file
            if isempty(regexp(filename, '^([a-zA-Z]:\\|[a-zA-Z]:/|\\\\|/)', 'ONCE'))
                filename = [pwd, filesep, char(filename)];
            end
            filename = char(javaMethod('getCanonicalPath', javaObject('java.io.File', filename)));
        end

        function str = list2str(list, varargin)
            % Convert a list to string
            %
            % s = Utils.list2str(l) converts the list l into a string with list
            % brackets '[' and ']'. If a list entry is a GAMS Symbol, its name
            % is used.
            % s = Utils.list2str(l, bl, bu) is as above, but with list brackets
            % bl and bu.
            %

            bracket_open = '[';
            bracket_close = ']';
            if nargin > 1
                bracket_open = varargin{1};
            end
            if nargin > 2
                bracket_close = varargin{2};
            end

            str = bracket_open;
            for i = 1:numel(list)
                if iscell(list)
                    elem = list{i};
                else
                    elem = list(i);
                end
                if ischar(elem) || isstring(elem)
                    str = sprintf('%s%s', str, elem);
                elseif isa(elem, 'GAMSTransfer.Symbol')
                    str = sprintf('%s%s', str, elem.name);
                else
                    str = sprintf('%s%g', str, elem);
                end
                if i < numel(list)
                    str = strcat(str, ',');
                end
            end
            str = strcat(str, bracket_close);
        end

    end

end
