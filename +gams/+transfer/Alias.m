% GAMS Alias Creator
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
% GAMS Alias Creator
%
% Creates a GAMS Alias and adds it to a container.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    name of alias
% 3. alias_with (Set or Alias):
%    gams.transfer.symbol.Set to be linked to.
%
% Example:
% c = Container();
% s = Set(c, 's');
% a = Alias(c, 'a', s);
%
% See also: gams.transfer.alias.Set, gams.transfer.Container.addAlias, gams.transfer.Set

%> @brief GAMS Alias Creator
%>
%> Creates a GAMS Alias and adds it to a container.
%>
%> **Required Arguments:**
%> 1. container (`Container`):
%>    \ref gams::transfer::Container "Container" object this symbol should be stored in
%> 2. name (`string`):
%>    name of alias
%> 3. alias_with (`Set` or `Alias`):
%>    \ref gams::transfer::symbol::Set "symbol.Set" to be linked to.
%>
%> **Example:**
%> ```
%> c = Container();
%> s = Set(c, 's');
%> a = Alias(c, 'a', s);
%> ```
%>
%> @see \ref gams::transfer::alias::Set "alias.Set", \ref gams::transfer::Container::addAlias
%> "Container.addAlias", \ref gams::transfer::Set "Set"
function alias = Alias(container, varargin)
    alias = container.addAlias(varargin{:});
end
