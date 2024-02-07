% GAMS Set Creator
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
% GAMS Set Creator
%
% Creates a GAMS Set and adds it to a container.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of set
%
% Optional Arguments:
% 3. domain (cellstr or Set):
%    List of domains given either as string or as reference to a
%    gams.transfer.symbol.Set object. Default is {"*"} (for 1-dim with universe domain).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is `[]`.
% - description (string):
%   Description of symbol. Default is "".
% - is_singleton (logical):
%   Indicates if set is a is_singleton set (true) or not (false). Default is false.
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case
%   they are not present in the domains already. With a logical vector domain forwarding
%   can be enabled/disabled independently for each domain. Default: false.
%
% Note, this method may overwrite a set if its definition (is_singleton, domain,
% domain_forwarding) doesn't differ.
%
% Example:
% c = Container();
% s1 = Set(c, 's1');
% s2 = Set(c, 's2', {s1, '*', '*'});
% s3 = Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%
% See also: gams.transfer.symbol.Set, gams.transfer.Container.addSet

%> @brief GAMS Set Creator
%>
%> **Required Arguments:**
%> 1. container (`Container`):
%>    \ref gams::transfer::Container "Container" object this symbol should be stored in
%> 2. name (`string`):
%>    Name of set
%>
%> **Optional Arguments:**
%> 3. domain (`cellstr` or `Set`):
%>    List of domains given either as `string` or as reference to a \ref
%>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{"*"}` (for 1-dim with
%>    universe domain).
%>
%> **Parameter Arguments:**
%> - records:
%>   Set records, e.g. a list of strings. Default is `[]`.
%> - description (`string`):
%>   Description of symbol. Default is `""`.
%> - is_singleton (`logical`):
%>   Indicates if set is a is_singleton set (`true`) or not (`false`). Default is `false`.
%> - domain_forwarding (`logical`):
%>   If `true`, domain entries in records will recursively be added to the domains in case
%>   they are not present in the domains already. With a logical vector domain forwarding
%>   can be enabled/disabled independently for each domain. Default: `false`.
%>
%> Note, this method may overwrite a set if its definition (\ref
%> gams::transfer::symbol::Set::is_singleton "is_singleton", \ref
%> gams::transfer::symbol::Set::domain "domain", \ref
%> gams::transfer::symbol::Set::domain_forwarding "domain_forwarding") doesn't differ.
%>
%> **Example:**
%> ```
%> c = Container();
%> s1 = Set(c, 's1');
%> s2 = Set(c, 's2', {s1, '*', '*'});
%> s3 = Set(c, 's3', '*', 'records', {'e1', 'e2', 'e3'}, 'description', 'set s3');
%> ```
%>
%> @see \ref gams::transfer::symbol::Set "symbol.Set", \ref gams::transfer::Container::addSet
%> "Container.addSet"
function symbol = Set(container, varargin)
    symbol = container.addSet(varargin{:});
end
