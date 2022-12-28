use core::fmt::Debug;
use regex::Regex;
use std::{cmp::max, collections::HashMap, fs};

#[derive(Debug, Default)]
struct Blueprint {
    pub num: u32,
    pub cost_ore_ore: u32,
    pub cost_clay_ore: u32,
    pub cost_obs_ore: u32,
    pub cost_obs_clay: u32,
    pub cost_geode_ore: u32,
    pub cost_geode_obs: u32,
}

impl Blueprint {
    fn max_ore_cost(&self) -> u32 {
        max(
            max(self.cost_ore_ore, self.cost_obs_ore),
            self.cost_geode_ore,
        )
    }
}

// Resources/Robots
#[derive(Copy, Clone, Debug)]
enum R {
    Ore,
    Clay,
    Obsidian,
    Geode,
}

impl R {
    pub fn bitshift(&self) -> u64 {
        match self {
            R::Ore => 24,
            R::Clay => 16,
            R::Obsidian => 8,
            R::Geode => 0,
        }
    }
}

#[derive(Clone, Copy)]
struct State {
    // Packing whole state into one u64
    // High-order u32 is robot state - One byte each for ore, clay, obsidian, geode
    // with geode being the low order byte
    // Low-order u32 is resource state (same order)
    state: u64,
}

impl State {
    // 1 ore robot, no resources
    pub fn new() -> State {
        let st = State { state: 0 };
        st.add_robot(R::Ore)
    }

    pub fn memo_key(&self, turns: u32) -> u64 {
        (self.state & 0xFFFFFFFFFFFFFF00) + turns as u64
    }

    pub fn resource(&self, kind: R) -> u32 {
        ((self.state >> kind.bitshift()) & 0xFF) as u32
    }

    pub fn num_robots(&self, kind: R) -> u32 {
        ((self.state >> (32 + kind.bitshift())) & 0xFF) as u32
    }

    pub fn can_afford_robot(&self, kind: R, blueprint: &Blueprint) -> bool {
        match kind {
            R::Ore => self.resource(R::Ore) >= blueprint.cost_ore_ore,
            R::Clay => self.resource(R::Ore) >= blueprint.cost_clay_ore,
            R::Obsidian => {
                self.resource(R::Ore) >= blueprint.cost_obs_ore
                    && self.resource(R::Clay) >= blueprint.cost_obs_clay
            }
            R::Geode => {
                self.resource(R::Ore) >= blueprint.cost_geode_ore
                    && self.resource(R::Obsidian) >= blueprint.cost_geode_obs
            }
        }
    }

    pub fn buy_robot(&self, kind: R, blueprint: &Blueprint) -> State {
        let mut s = State { state: self.state };
        let pay = |state: &mut State, kind: R, amount: u32| {
            state.state -= (amount << kind.bitshift()) as u64;
        };
        match kind {
            R::Ore => pay(&mut s, R::Ore, blueprint.cost_ore_ore),
            R::Clay => pay(&mut s, R::Ore, blueprint.cost_clay_ore),
            R::Obsidian => {
                pay(&mut s, R::Ore, blueprint.cost_obs_ore);
                pay(&mut s, R::Clay, blueprint.cost_obs_clay);
            }
            R::Geode => {
                pay(&mut s, R::Ore, blueprint.cost_geode_ore);
                pay(&mut s, R::Obsidian, blueprint.cost_geode_obs);
            }
        };
        s.add_robot(kind)
    }

    pub fn add_robot(&self, kind: R) -> State {
        let mut new_s = self.clone();
        new_s.state += 1 << (kind.bitshift() + 32);
        new_s
    }

    #[allow(unused)]
    pub fn add_resource(&self, kind: R, amount: u64) -> State {
        let mut new_s = self.clone();
        new_s.state += amount << (kind.bitshift());
        new_s
    }

    pub fn collect(&self) -> State {
        let robots = ((self.state >> 32) & 0xFFFFFFFF) as u64;
        State {
            state: self.state + robots,
        }
    }
}

impl Debug for State {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let robots = ((self.state >> 32) & 0xFFFFFFFF) as u32;
        let res = (self.state & 0xFFFFFFFF) as u32;
        write!(f, "Robots: {:?}\n", robots.to_be_bytes())?;
        write!(f, "Resources: {:?}\n", res.to_be_bytes())
    }
}

fn parse_line(line: &str) -> Blueprint {
    let re = Regex::new("-?(\\d)+").unwrap();
    let nums: Vec<u32> = re
        .find_iter(line)
        .map(|s| s.as_str().parse().unwrap())
        .collect();
    Blueprint {
        num: nums[0],
        cost_ore_ore: nums[1],
        cost_clay_ore: nums[2],
        cost_obs_ore: nums[3],
        cost_obs_clay: nums[4],
        cost_geode_ore: nums[5],
        cost_geode_obs: nums[6],
    }
}

fn should_early_out(state: State, turns: u32, max_so_far: u32) -> bool {
    if state.resource(R::Geode) + state.num_robots(R::Geode) * turns + (turns * (turns - 1) / 2)
        <= max_so_far
    {
        return true;
    }
    false
}

fn find_max(
    bp: &Blueprint,
    state: State,
    turns: u32,
    max_so_far: u32,
    memo_map: &mut HashMap<u64, u32>,
) -> u32 {
    if turns == 0 {
        return state.resource(R::Geode);
    }
    if state.can_afford_robot(R::Geode, &bp) {
        let s = state.collect().buy_robot(R::Geode, &bp);
        return find_max(bp, s, turns - 1, max_so_far, memo_map);
    }
    if memo_map.contains_key(&state.memo_key(turns)) {
        return *memo_map.get(&state.memo_key(turns)).unwrap();
    }
    if should_early_out(state, turns, max_so_far) {
        return 0;
    }
    let mut max = max_so_far;
    for kind in [R::Obsidian, R::Clay, R::Ore] {
        if let R::Ore = kind {
            // Don't bother making more ore robots than the max ore cost of a robot
            if state.num_robots(R::Ore) >= bp.max_ore_cost() {
                continue;
            }
        }

        if state.can_afford_robot(kind, bp) {
            // println!("Buying {:?}", kind);
            let s = state.collect().buy_robot(kind, &bp);
            let score = find_max(bp, s, turns - 1, max, memo_map);
            memo_map.insert(s.memo_key(turns - 1), score);
            if score > max {
                max = score;
            }
        }
    }
    let score = find_max(bp, state.collect(), turns - 1, max, memo_map);
    memo_map.insert(state.collect().memo_key(turns - 1), score);
    if score > max {
        max = score;
    }
    return max;
}

fn load_blueprints() -> Vec<Blueprint> {
    let contents = fs::read_to_string("input.txt").unwrap();
    contents
        .split("\n")
        .map(|s| s.to_string())
        .map(|line| parse_line(&line))
        .collect()
}

pub fn part1() {
    let blueprints = load_blueprints();
    let mut sum = 0;
    for bp in &blueprints {
        println!("Blueprint {}:", bp.num);
        let mut memo_map = HashMap::new();
        let max = find_max(&bp, State::new(), 24, 0, &mut memo_map);
        let quality = bp.num * max;
        sum += quality;
        println!("Blueprint[{}]: max: {}, quality {}", bp.num, max, quality);
    }
    println!("Part 1: {}", sum);
}

pub fn part2() {
    let blueprints = load_blueprints();
    let mut product = 1;
    for bp in &blueprints[0..3] {
        println!("Blueprint {}:", bp.num);
        let mut memo_map = HashMap::new();
        let max = find_max(&bp, State::new(), 32, 0, &mut memo_map);
        product *= max;
        println!("Blueprint[{}] after 32 mins: max: {}", bp.num, max);
    }
    println!("Part 2: {}", product);
}

#[cfg(test)]
mod tests {
    use super::*;
    const BP1_LINE: &str = "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.";

    #[test]
    pub fn test_can_parse_line() {
        let bp = parse_line(BP1_LINE);
        assert_eq!(1, bp.num);
        assert_eq!(4, bp.cost_ore_ore);
        assert_eq!(2, bp.cost_clay_ore);
        assert_eq!(3, bp.cost_obs_ore);
        assert_eq!(14, bp.cost_obs_clay);
        assert_eq!(2, bp.cost_geode_ore);
        assert_eq!(7, bp.cost_geode_obs);
    }

    #[test]
    pub fn test_state_basics() {
        let mut s = State::new();
        s = s.collect();
        assert_eq!(1, s.resource(R::Ore));
        assert_eq!(0, s.resource(R::Clay));
        assert_eq!(0, s.resource(R::Obsidian));
        assert_eq!(0, s.resource(R::Geode));
        s = s.add_robot(R::Clay);
        s = s.collect();
        assert_eq!(1, s.resource(R::Clay));
        assert_eq!(0, s.resource(R::Obsidian));
        assert_eq!(0, s.resource(R::Geode));
    }

    #[test]
    pub fn test_can_afford_robot() {
        let bp = parse_line(BP1_LINE);
        let mut s = State::new();
        s = s.add_resource(R::Ore, 2);
        assert!(!s.can_afford_robot(R::Ore, &bp));
        assert!(s.can_afford_robot(R::Clay, &bp));
        assert!(!s.can_afford_robot(R::Obsidian, &bp));
        assert!(!s.can_afford_robot(R::Geode, &bp));
        s = s.add_resource(R::Obsidian, 7);
        assert!(s.can_afford_robot(R::Geode, &bp));
    }

    #[test]
    pub fn test_buy_robot() {
        let bp = parse_line(BP1_LINE);
        let mut s = State::new();
        assert_eq!(0, s.resource(R::Ore));
        s = s.add_resource(R::Ore, 2);
        assert_eq!(2, s.resource(R::Ore));
        assert!(s.can_afford_robot(R::Clay, &bp));
        s = s.buy_robot(R::Clay, &bp);
        assert_eq!(0, s.resource(R::Ore));
    }
}
