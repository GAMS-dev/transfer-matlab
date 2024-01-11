% GAMS Variable Creator
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
% GAMS Variable Creator
%
% Creates a GAMS Variable and adds it to a container.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of variable
%
% Optional Arguments:
% 3. type (string, int or gams.transfer.VariableType):
%    Specifies the variable type, either as string, as integer given by any of the
%    constants in gams.transfer.VariableType or
%    gams.transfer.VariableType. Default is "free".
% 4. domain (cellstr or Set):
%    List of domains given either as string or as reference to a
%    gams.transfer.symbol.Set object. Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Set records, e.g. a list of strings. Default is [].
% - description (string):
%   Description of symbol. Default is "".
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case
%   they are not present in the domains already. With a logical vector domain forwarding
%   can be enabled/disabled independently for each domain. Default: false.
%
% Note, this method may overwrite a variable if its definition (type, domain,
% domain_forwarding) doesn't differ.
%
% Example:
% c = Container();
% v1 = Variable(c, 'v1');
% v2 = Variable(c, 'v2', 'binary', {'*', '*'});
% v3 = Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
%
% See also: gams.transfer.symbol.Variable, gams.transfer.Container.addVariable,
% gams.transfer.VariableType

%> @brief GAMS Variable Creator
%>
%> **Required Arguments:**
%> 1. container (`Container`):
%>    \ref gams::transfer::Container "Container" object this symbol should be stored in
%> 2. name (`string`):
%>    Name of variable
%>
%> **Optional Arguments:**
%> 3. type (`string`, `int` or \ref gams::transfer::VariableType "VariableType"):
%>    Specifies the variable type, either as `string`, as `integer` given by any of the
%>    constants in \ref gams::transfer::VariableType "VariableType" or \ref
%>    gams::transfer::VariableType "VariableType". Default is `"free"`.
%> 4. domain (`cellstr` or `Set`):
%>    List of domains given either as string or as reference to a \ref
%>    gams::transfer::symbol::Set "symbol.Set" object. Default is `{}` (for scalar).
%>
%> **Parameter Arguments:**
%> - records:
%>   Set records, e.g. a list of strings. Default is `[]`.
%> - description (`string`):
%>   Description of symbol. Default is `""`.
%> - domain_forwarding (`logical`):
%>   If `true`, domain entries in records will recursively be added to the domains in case
%>   they are not present in the domains already. With a logical vector domain forwarding
%>   can be enabled/disabled independently for each domain. Default: `false`.
%>
%> Note, this method may overwrite a variable if its definition (\ref
%> gams::transfer::symbol::Variable::type "type", \ref
%> gams::transfer::symbol::Variable::domain "domain", \ref
%> gams::transfer::symbol::Variable::domain_forwarding "domain_forwarding") doesn't differ.
%>
%> **Example:**
%> ```
%> c = Container();
%> v1 = Variable(c, 'v1');
%> v2 = Variable(c, 'v2', 'binary', {'*', '*'});
%> v3 = Variable(c, 'v3', VariableType.BINARY, '*', 'description', 'var v3');
%> ```
%>
%> @see \ref gams::transfer::symbol::Variable "symbol.Variable", \ref
%> gams::transfer::Container::addVariable "Container.addVariable", \ref
%> gams::transfer::VariableType "VariableType"
function symbol = Variable(container, varargin)
    symbol = container.addVariable(varargin{:});
end
