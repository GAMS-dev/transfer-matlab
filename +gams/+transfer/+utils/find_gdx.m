% Find GDX library from PATH
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
% Find GDX library from PATH
%
% sysdir = find_gdx() returns the path to the GAMS system directory if it is
% part of the PATH environment variable and an empty string otherwise.
function gdx_path = find_gdx()
    gdx_path = '';

    % find gdx in any of the PATH paths
    paths = [pathsep, getenv('PATH'), pathsep];
    idx = find(paths == pathsep);
    for i = 1:numel(idx)-1
        p = paths(idx(i)+1:idx(i+1)-1);
        if isfile(fullfile(p, gams.transfer.Constants.GDX_LIB_NAME))
            gdx_path = p;
            break;
        end
    end

    % trim path
    if numel(gdx_path) > 0 && strcmp(gdx_path(end), filesep)
        gdx_path = gdx_path(1:end-1);
    end

    if numel(gdx_path) == 0
        error('Cannot find GDX library from PATH.');
    end
end
