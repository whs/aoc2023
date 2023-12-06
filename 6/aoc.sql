DROP FUNCTION IF EXISTS parse;
DROP FUNCTION IF EXISTS solve1;
DROP FUNCTION IF EXISTS solve1_arr;
DROP TYPE IF EXISTS problem;

CREATE TYPE problem AS
(
    time     BIGINT,
    distance BIGINT
);

CREATE FUNCTION parse(input TEXT) RETURNS problem[] AS
$$
DECLARE
    inputTrim text   := trim(both E'\r\n' from input);
    lines     text[] := regexp_split_to_array(inputTrim, '\n');
    times     text[] := array(SELECT regexp_matches(lines[1], '\d+', 'g'));
    distances text[] := array(SELECT regexp_matches(lines[2], '\d+', 'g'));
    out       problem[];
    i         BIGINT;
BEGIN
    FOR i IN 1..array_length(times, 1)
        LOOP
            out = array_append(out, (times[i][1], distances[i][1])::problem);
        END LOOP;
    RETURN out;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION solve1(problem) RETURNS BIGINT AS
$$
DECLARE
    hold_duration           BIGINT;
    remaining_duration BIGINT;
    travel_distance BIGINT;
    winning_ways BIGINT := 0;
BEGIN
    FOR hold_duration IN 1..($1.time-1)
    LOOP
        remaining_duration = $1.time - hold_duration;
        travel_distance = remaining_duration * hold_duration;
        IF travel_distance > $1.distance THEN
            winning_ways = winning_ways + 1;
        end if;
    END LOOP;
    RETURN winning_ways;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION solve1_arr(problem[]) RETURNS BIGINT AS
$$
DECLARE
    acc BIGINT := 1;
    problem problem;
BEGIN
    FOREACH problem IN ARRAY $1
    LOOP
        -- RAISE NOTICE '%', to_json(times);
        acc = acc * solve1(problem);
    END LOOP;
    RETURN acc;
END
$$ LANGUAGE plpgsql;

-- Part 1
-- SELECT solve1_arr((parse($input$
-- Time:      7  15   30
-- Distance:  9  40  200
-- $input$)));
-- SELECT solve1_arr((parse($input$
-- Time:        46     85     75     82
-- Distance:   208   1412   1257   1410
-- $input$)));

-- Part 2
SELECT solve1_arr((parse($input$
Time:        46857582
Distance:   208141212571410
$input$)));

