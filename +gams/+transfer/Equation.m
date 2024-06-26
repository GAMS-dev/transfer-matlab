% GAMS Equation Creator
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
% GAMS Equation Creator
%
% Creates a GAMS Equation and adds it to a container.
%
% Required Arguments:
% 1. container (Container):
%    gams.transfer.Container object this symbol should be stored in
% 2. name (string):
%    Name of equation
% 3. type (string, int or gams.transfer.EquationType):
%    Specifies the variable type, either as string, as integer given by any of the constants in
%    gams.transfer.EquationType or gams.transfer.EquationType.
%
% Optional Arguments:
% 4. domain (cellstr or Set):
%    List of domains given either as string or as reference to a gams.transfer.symbol.Set object.
%    Default is {} (for scalar).
%
% Parameter Arguments:
% - records:
%   Equation records. Default is [].
% - description (string):
%   Description of symbol. Default is "".
% - domain_forwarding (logical):
%   If true, domain entries in records will recursively be added to the domains in case they are not
%   present in the domains already. With a logical vector domain forwarding can be enabled/disabled
%   independently for each domain. Default: false.
%
% Note, this method may overwrite an equation if its definition (type, domain, domain_forwarding)
% doesn't differ.
%
% Example:
% c = Container();
% e2 = Equation(c, 'e2', 'l', {'*', '*'});
% e3 = Equation(c, 'e3', EquationType.EQ, '*', 'description', 'equ e3');
%
% See also: gams.transfer.symbol.Equation, gams.transfer.Container.addEquation,
% gams.transfer.EquationType

%> @brief GAMS Equation Creator
%>
%> Creates a GAMS Equation and adds it to a container.
%>
%> **Required Arguments:**
%> 1. container (`Container`):
%>    \ref gams::transfer::Container "Container" object this symbol should be stored in
%> 2. name (`string`):
%>    Name of equation
%> 3. type (`string`, `int` or \ref gams::transfer::EquationType "EquationType"):
%>    Specifies the variable type, either as `string`, as `integer` given by any of the constants in
%>    \ref gams::transfer::EquationType "EquationType" or \ref gams::transfer::EquationType
%>    "EquationType".
%>
%> **Optional Arguments:**
%> 4. domain (`cellstr` or `Set`):
%>    List of domains given either as `string` or as reference to a \ref gams::transfer::symbol::Set
%>    "symbol.Set" object. Default is `{}` (for scalar).
%>
%> **Parameter Arguments:**
%> - records:
%>   Equation records. Default is `[]`.
%> - description (`string`):
%>   Description of symbol. Default is `""`.
%> - domain_forwarding (`logical`):
%>   If `true`, domain entries in records will recursively be added to the domains in case they are
%>   not present in the domains already. With a logical vector domain forwarding can be
%>   enabled/disabled independently for each domain. Default: `false`.
%>
%> Note, this method may overwrite an equation if its definition (\ref
%> gams::transfer::symbol::Equation::type "type", \ref gams::transfer::symbol::Equation::domain
%> "domain", \ref gams::transfer::symbol::Equation::domain_forwarding "domain_forwarding") doesn't
%> differ.
%>
%> **Example:**
%> ```
%> c = Container();
%> e2 = Equation(c, 'e2', 'l', {'*', '*'});
%> e3 = Equation(c, 'e3', EquationType.EQ, '*', 'description', 'equ e3');
%> ```
%>
%> @see \ref gams::transfer::symbol::Equation "symbol.Equation", \ref
%> gams::transfer::Container::addEquation "Container.addEquation", \ref gams::transfer::EquationType
%> "EquationType"
function symbol = Equation(container, varargin)
    symbol = container.addEquation(varargin{:});
end
