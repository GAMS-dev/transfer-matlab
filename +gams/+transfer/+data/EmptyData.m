classdef EmptyData < gams.transfer.data.AbstractData

    properties (Dependent, SetAccess = private)
        labels
    end

    methods

        function labels = get.labels(obj)
            labels = [obj.domain_labels, obj.value_labels];
        end

    end

    methods

        function obj = EmptyData(varargin)

            % parse input arguments
            p = inputParser();
            addRequired(p, 'domains', ...
                @(x) validateattributes(x, {'cell'}, {'nonempty'}, 'Empty', 'domains', 1));
            parse(p, varargin{:});

            obj.domains = p.Results.domains;
            obj.records = [];
        end

        function name = name(obj)
            name = 'empty';
        end

        function [flag, msg] = isValid(obj)
            [need_eval, flag, msg] = obj.getStatus();
            if ~need_eval
                return
            end

            obj.setStatus('ok');

            if ~isempty(obj.records)
                obj.setStatus('records must be empty.');
                [need_eval, flag, msg] = obj.getStatus();
                assert(~need_eval);
                return
            end

            if ~isempty(obj.value_labels_)
                obj.setStatus('value_labels must be empty.');
                [need_eval, flag, msg] = obj.getStatus();
                assert(~need_eval);
                return
            end

            for i = 1:numel(obj.domains_)
                [elem_flag, elem_msg] = obj.domains_{i}.isValid();
                if ~elem_flag
                    obj.setStatus(sprintf('Domain %d is invalid: %s.', i, elem_msg));
                    break;
                end
            end

            [need_eval, flag, msg] = obj.getStatus();
            assert(~need_eval);
        end

    end
end
