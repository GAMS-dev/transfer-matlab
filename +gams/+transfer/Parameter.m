% GAMS Parameter Creator
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
% GAMS Parameter Creator
%
% Creates a GAMS Parameter and adds it to a container.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of parameter
%
% Optional Arguments:
% 3. domain (cellstr or Set):
%    List of domains given either as string or as reference to a
%    gams.transfer.symbol.Set object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Parameter records. Default is [].
% - description (string):
%   Description of symbol. Default is "".
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case
%   they are not present in the domains already. With a logical vector domain
%   forwarding can be enabled/disabled independently for each domain. Default: false.
%
% Note, this method may overwrite a parameter if its definition (domain,
% domain_forwarding) doesn't differ.
%
% Example:
% c = Container();
% p1 = Parameter(c, 'p1');
% p2 = Parameter(c, 'p2', {'*', '*'});
% p3 = Parameter(c, 'p3', '*', 'description', 'par p3');
%
% See also: gams.transfer.symbol.Parameter, gams.transfer.Container.addParameter

%> @brief GAMS Parameter Creator
%>
%> **Required Arguments:**
%> 1. container (`Container`):
%>    \ref gams::transfer::Container "Container" object this symbol should be stored in
%> 2. name (`string`):
%>    Name of parameter
%>
%> **Optional Arguments:**
%> 3. domain (`cellstr` or `Set`):
%>    List of domains given either as `string` or as reference to a \ref
%>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
%>
%> **Parameter Arguments:**
%> - records:
%>   Parameter records. Default is `[]`.
%> - description (`string`):
%>   Description of symbol. Default is `""`.
%> - domain_forwarding (`logical`):
%>   If `true`, domain entries in records will recursively be added to the domains in case
%>   they are not present in the domains already. With a logical vector domain forwarding
%>   can be enabled/disabled independently for each domain. Default: `false`.
%>
%> Note, this method may overwrite a parameter if its definition (\ref
%> gams::transfer::symbol::Parameter::domain "domain", \ref
%> gams::transfer::symbol::Parameter::domain_forwarding "domain_forwarding") doesn't differ.
%>
%> **Example:**
%> ```
%> c = Container();
%> p1 = Parameter(c, 'p1');
%> p2 = Parameter(c, 'p2', {'*', '*'});
%> p3 = Parameter(c, 'p3', '*', 'description', 'par p3');
%> ```
%>
%> @see \ref gams::transfer::symbol::Parameter "symbol.Parameter", \ref
%> gams::transfer::Container::addParameter "Container.addParameter"
function symbol = Parameter(container, varargin)
    symbol = container.addParameter(varargin{:});
end
