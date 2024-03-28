function results = benchmark_read_write(varargin)

    p = inputParser();
    is_string_char = @(x) (isstring(x) && numel(x) == 1 || ischar(x)) && ...
        ~strcmpi(x, 'working_dir') && ~strcmpi(x, 'gams_dir') && ~strcmpi(x, 'format');
    addRequired(p, 'gdx_dir');
    addParameter(p, 'format', 'struct', is_string_char)
    addParameter(p, 'working_dir', tempname, is_string_char);
    addParameter(p, 'check_same', false, @islogical);
    addParameter(p, 'gams_dir', gams.transfer.find_gams(), is_string_char);
    parse(p, varargin{:});

    files = dir(fullfile(p.Results.gdx_dir, '**', '*.gdx'));

    results.name = cell(numel(files), 1);
    results.read_size = nan(numel(files), 1);
    results.read_time = nan(numel(files), 1);
    results.read_speed = nan(numel(files), 1);
    results.write_size = nan(numel(files), 1);
    results.write_time = nan(numel(files), 1);
    results.write_speed = nan(numel(files), 1);
    results.same = -ones(numel(files), 1);
    results.file = cell(numel(files), 1);

    mkdir(p.Results.working_dir);
    write_filename = fullfile(p.Results.working_dir, 'write.gdx');
    gdxdiff = fullfile(p.Results.gams_dir, 'gdxdiff');

    oldfolder = cd(p.Results.working_dir);

    all_bytes = 0;
    curr_bytes = 0;
    for i = 1:numel(files)
        all_bytes = all_bytes + files(i).bytes;
    end

    for i = 1:numel(files)
        results.name{i} = files(i).name;
        results.file{i} = fullfile(files(i).folder, files(i).name);
        read_filename = fullfile(p.Results.working_dir, 'read.gdx');
        results.read_size(i) = files(i).bytes / 1024 / 1024;

        if mod(i, 20) == 1
            fprintf([repmat('-', 1, 5), '+', repmat('-', 1, 22), '+', repmat('-', 1, 29), '+', repmat('-', 1, 29), '+', repmat('-', 1, 6), '+', repmat('-', 1, 30), '\n'])
            fprintf('     | %20s | %27s | %27s | %4s | %s\n', '', 'read' , 'write', '', '')
            fprintf('     | %20s | %5s %10s %10s | %5s %10s %10s | %4s | %s\n', 'name', 'MB' , 's', 'MB/s', 'MB', 's', 'MB/s', 'same', 'file')
            fprintf([repmat('-', 1, 5), '+', repmat('-', 1, 22), '+', repmat('-', 1, 29), '+', repmat('-', 1, 29), '+', repmat('-', 1, 6), '+', repmat('-', 1, 30), '\n'])
        end
        fprintf('%3d%% | %20s | ', floor(curr_bytes / all_bytes * 100), results.name{i});

        try
            curr_bytes = curr_bytes + files(i).bytes;
            copyfile(results.file{i}, read_filename);

            gdx = gams.transfer.Container('gams_dir', p.Results.gams_dir);

            fprintf('%5.0f ', results.read_size(i));

            time = tic();
            gdx.read(read_filename, 'format', p.Results.format);
            results.read_time(i) = toc(time);
            results.read_speed(i) = results.read_size(i) / results.read_time(i);

            fprintf('%10.2f %10.2f | ', results.read_time(i), results.read_speed(i));

            time = tic();
            gdx.write(write_filename);
            results.write_time(i) = toc(time);

            clearvars -except i p files results oldfolder all_bytes curr_bytes gdxdiff read_filename write_filename

            write_file = dir(write_filename);
            results.write_size(i) = write_file.bytes / 1024 / 1024;
            results.write_speed(i) = results.write_size(i) / results.write_time(i);

            fprintf('%5.0f %10.2f %10.2f | ', results.write_size(i), results.write_time(i), results.write_speed(i));

            if p.Results.check_same
                [status, ~] = system(sprintf('%s %s %s EPS=1e-20 RELEPS=1e-20', gdxdiff, read_filename, write_filename));
                results.same(i) = status == 0;
            end

            fprintf('%4d | %s\n', results.same(i), results.file{i});
        catch e
            fprintf(' *** FAIL: %s\n', e.message);
        end
    end

    cd(oldfolder);
    try
        rmdir(p.Results.working_dir, 's');
    catch
    end

    results = struct2table(results);

end
