DROP TABLE IF EXISTS input;
DROP TABLE IF EXISTS chars;
DROP TABLE IF EXISTS leftright;
DROP TABLE IF EXISTS bpgroups;
DROP TABLE IF EXISTS charpresence;
DROP TABLE IF EXISTS badges;

.import input.txt input

CREATE TABLE chars AS
WITH RECURSIVE split(char, rest) AS (
  VALUES('a', 'bcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
  UNION ALL
  SELECT substr(rest, 1, 1),
    substr(rest, 2)
  FROM split
  WHERE rest <> ''
)
SELECT char
FROM split;

CREATE TABLE leftright AS
SELECT
    substr(backpack, 1, length(backpack) / 2 ) as left,
    substr(backpack, length(backpack) / 2 + 1, length(backpack) / 2 ) as right
FROM input;

-- Part 1 solution
SELECT
    SUM(chars.rowid)
FROM
    chars INNER JOIN leftright
WHERE
    INSTR(left, char)
AND
    INSTR(right, char);

CREATE TABLE bpgroups
AS
SELECT
    backpack,
    (rowid - 1) % 3 as idingroup,
    cast ( ((rowid - 1) / 3) as int ) - ( ((rowid - 1) / 3) < cast ( ((rowid - 1) / 3) as int )) as bpgroup
FROM input;

CREATE TABLE charpresence
AS
SELECT
    char,
    chars.rowid as priority,
    bpgroup,
    idingroup
FROM
    chars INNER JOIN bpgroups
WHERE
    INSTR(backpack, char);

CREATE TABLE badges
AS
SELECT
    bpgroup, char, priority, count(*) as cnt
FROM charpresence
GROUP BY bpgroup, char, priority
HAVING cnt = 3;

-- Part 2 solution
SELECT SUM(priority)
FROM badges;