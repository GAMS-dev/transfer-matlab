classdef GAMSTest < handle
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

    properties
        name
        start_time
        tests = {}
    end

    methods

        function obj = GAMSTest(name)
            obj.name = name;
            obj.start_time = tic;
        end

        function add(obj, testname);
            obj.result();
            obj.tests{end+1} = struct('name', testname, 'asserts', '');
        end

        function assert(obj, condition)
            if condition
                obj.tests{end}.asserts = [obj.tests{end}.asserts, '.'];
            else
                obj.tests{end}.asserts = [obj.tests{end}.asserts, 'x'];
            end
        end

        function assertEquals(obj, val1, val2)
            if isa(val1, 'handle') && isa(val2, 'handle')
                obj.assert(val1 == val2);
            else
                obj.assert(isequaln(val1, val2));
            end
        end

        function reset(obj)
            obj.tests{end}.asserts(end) = '.';
        end

        function result(obj)
            if numel(obj.tests) == 0
                return
            end
            fails = strfind(obj.tests{end}.asserts, 'x');
            if ~isempty(fails);
                fprintf('*** FAIL: %s/%s (%s | fails: ', obj.name, obj.tests{end}.name, obj.tests{end}.asserts);
                for i = 1:numel(fails)
                    fprintf('%d', fails(i));
                    if i < numel(fails)
                        fprintf(',');
                    end
                end
                fprintf(')\n');
            end
        end

        function [n_tests, n_fails] = summary(obj)
            obj.result();
            time = toc(obj.start_time);
            n_fails = 0;
            n_tests = 0;
            for i = 1:numel(obj.tests)
                fails = strfind(obj.tests{i}.asserts, 'x');
                n_fails = n_fails + numel(fails);
                n_tests = n_tests + numel(obj.tests{i}.asserts);
            end
            fprintf('Test Summary (%20s): %3d testsets (%5d tests), %5.2f s, %3d failures. ', obj.name, numel(obj.tests), n_tests, time, n_fails);
            if n_fails > 0
                fprintf('FAIL!\n');
            else
                fprintf('OK!\n');
            end
        end

    end

    methods

        function testEmptySymbol(obj, symbol)
            switch class(symbol)
            case {'gams.transfer.symbol.Set', 'gams.transfer.symbol.Parameter', 'gams.transfer.symbol.Variable', 'gams.transfer.symbol.Equation'}
                obj.assert(ischar(symbol.name));
                obj.assert(ischar(symbol.description));
                obj.assert(symbol.dimension >= 0);
                obj.assert(iscell(symbol.domain));
                obj.assert(numel(symbol.domain) == symbol.dimension);
                obj.assert(iscell(symbol.domain_labels));
                obj.assert(ischar(symbol.domain_type));
                obj.assert(isnumeric(symbol.size));
                obj.assert(numel(symbol.size) == symbol.dimension);
                obj.assert(symbol.getNumberRecords() >= 0);
                obj.assert(symbol.getNumberValues() == 0 || isnan(symbol.getNumberValues()));
                obj.assert(islogical(symbol.isValid()));
                obj.assert(ischar(symbol.format));
            case 'gams.transfer.alias.Set'
                obj.assert(ischar(symbol.name));
                obj.assert(isa(symbol.alias_with, 'gams.transfer.symbol.Set'));
            otherwise
                obj.assert(false);
            end
            switch class(symbol)
            case 'gams.transfer.symbol.Set'
                obj.assert(islogical(symbol.is_singleton));
            case 'gams.transfer.symbol.Variable'
                obj.assert(ischar(symbol.type));
                obj.assertEquals(lower(gams.transfer.VariableType(symbol.type).select), symbol.type);
            case 'gams.transfer.symbol.Equation'
                obj.assert(ischar(symbol.type));
                obj.assertEquals(lower(gams.transfer.EquationType(symbol.type).select), symbol.type);
            end
        end

        function testGdxDiff(obj, filename1, filename2)
            filepath = fileparts(filename1);
            cmd = sprintf('gdxdiff %s %s EPS=1e-20 RELEPS=1e-20', filename1, filename2);
            oldfolder = cd(filepath);
            [status, stdout] = system(cmd);
            obj.assert(status == 0);
            if status
                display(stdout);
                system('gdxdump diffile.gdx');
            end
            cd(oldfolder);
        end

    end

end
