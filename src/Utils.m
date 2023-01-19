% GAMSTransfer Utilities
%
% ------------------------------------------------------------------------------
%
% GAMS - General Algebraic Modeling System
% GAMS Transfer Matlab
%
% Copyright (c) 2020-2023 GAMS Software GmbH <support@gams.com>
% Copyright (c) 2020-2023 GAMS Development Corp. <support@gams.com>
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
% GAMSTransfer Utilities
%
% Collection of utility functions used by GAMSTransfer
%
classdef Utils

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

            feature_support = struct('categorical', true, 'table', true, ...
                'c_prop_setget', true, 'handle_compare', true);

            if exist('OCTAVE_VERSION', 'builtin') > 0
                feature_support.categorical = false;
                feature_support.table = false;
                feature_support.c_prop_setget = false;
                feature_support.handle_compare = false;
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

            if strcmp(gams_dir, '')
                gams_dir = GAMSTransfer.find_gams();
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

    methods (Static, Hidden)

        function values = getAvailableValueFields(symbol, values)

            % get value fields of records
            switch GAMSTransfer.RecordsFormat.str2int(symbol.format)
            case {GAMSTransfer.RecordsFormat.EMPTY, GAMSTransfer.RecordsFormat.UNKNOWN}
                values = {};
                return
            case GAMSTransfer.RecordsFormat.TABLE
                fields = symbol.records.Properties.VariableNames;
            otherwise
                fields = fieldnames(symbol.records);
            end

            % get all supported value fields of symbol
            if isfield(symbol, 'symbol_type')
                switch symbol.symbol_type
                case 'parameter'
                    possible_values = {'value'};
                case {'variable', 'equation'}
                    possible_values = {'level', 'marginal', 'lower', 'upper', 'scale'};
                otherwise
                    possible_values = {};
                end
            elseif isa(symbol, 'GAMSTransfer.Parameter')
                possible_values = {'value'};
            elseif isa(symbol, 'GAMSTransfer.Variable') || isa(symbol, 'GAMSTransfer.Equation')
                possible_values = {'level', 'marginal', 'lower', 'upper', 'scale'};
            else
                possible_values = {};
            end

            % intersect requested with possible
            if nargin == 1
                values = possible_values;
            else
                values = intersect(possible_values, values);
            end
            values = intersect(fields, values);
        end

        function domain = getInd2Domain(symbol, is_indexed, idx)
            domain = cell(1, symbol.dimension);
            is_numeric_domain = true(1, symbol.dimension);
            domain_labels = symbol.domain_labels;
            if symbol.dimension == 0
                return;
            end

            % check if we have categorical
            features = GAMSTransfer.Utils.checkFeatureSupport();

            % get linear index
            switch GAMSTransfer.RecordsFormat.str2int(symbol.format)
            case {GAMSTransfer.RecordsFormat.STRUCT, GAMSTransfer.RecordsFormat.TABLE}
                for i = 1:symbol.dimension
                    k = symbol.records.(domain_labels{i})(idx);
                    if features.categorical && iscategorical(k)
                        domain{i} = char(k);
                        is_numeric_domain(i) = false;
                    else
                        domain{i} = double(k);
                    end
                end
            case {GAMSTransfer.RecordsFormat.DENSE_MATRIX, GAMSTransfer.RecordsFormat.SPARSE_MATRIX}
                k = cell(1, 20);
                [k{:}] = ind2sub(symbol.size, idx);
                for i = 1:numel(domain)
                    domain{i} = k{i};
                end
            end

            % convert to uel labels
            if ~is_indexed
                for i = 1:symbol.dimension
                    if ~is_numeric_domain(i)
                        continue
                    end
                    if isa(symbol, 'GAMSTransfer.Symbol')
                        d = symbol.getUELs(i, domain{i});
                        domain{i} = d{1};
                    elseif isfield(symbol, 'uels')
                        domain{i} = symbol.uels{i}{domain{i}};
                    else
                        domain{i} = nan;
                    end
                end
            end
        end

    end

end
