// Run with deno run --allow-read
import { lodash as _ } from 'https://raw.githubusercontent.com/lodash/lodash/4.17.21-es/lodash.js';

const file = await Deno.readTextFile("./input.txt");
const lines = file.split('\n')
const isInt = Number.isInteger;
const isArray = Array.isArray;

const cmp = (l, r) => {
    if (isInt(l) && isInt(r)) return r - l;
    if (isArray(l) && isArray(r)) {
        for (let i = 0; i < l.length && i < r.length; ++i) {
            const cmp_elems = cmp(l[i], r[i]);
            if (cmp_elems != 0) return cmp_elems;
        }
        return r.length - l.length;
    }
    if (isArray(l) && isInt(r)) return cmp(l, [r]);
    if (isInt(l) && isArray(r)) return cmp([l], r);
    return 0;
}

const part1 = _.chain(lines)
    .map(eval)
    .filter((v) => v != undefined)    
    .chunk(2)
    .map(([l, r]) => cmp(l, r))
    .pickBy((result) => result > 0)
    .keys()
    .map((i) => parseInt(i))
    .map((i) => i + 1)
    .sum()
    .value();

console.log("Part 1: " + part1);

const part2Array = _.chain(lines).map(eval).filter((v) => v != undefined).value();

const markers = [[[2]], [[6]]];
part2Array.push(markers[0]);
part2Array.push(markers[1]);
part2Array.sort(cmp).reverse();
const m1Loc = _.findIndex(part2Array, (a) => a == markers[0]);
const m2Loc = _.findIndex(part2Array, (a) => a == markers[1]);
console.log("Part 2: " + ((m1Loc + 1) * (m2Loc + 1)));
