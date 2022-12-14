use core::fmt::Debug;
use regex::Regex;
use std::{cmp::max, fs};

// Because this is only available on nightly at present
fn div_ceil(a: u32, b: u32) -> u32 {
    let r = a as f32 / b as f32;
    r.ceil() as u32
}

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
        *[
            self.cost_ore_ore,
            self.cost_clay_ore,
            self.cost_obs_ore,
            self.cost_geode_ore,
        ]
        .iter()
        .max()
        .unwrap()
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

    // Will return -1 if the robot can never be bought
    pub fn turns_to_buy_robot(&self, kind: R, bp: &Blueprint) -> i32 {
        match kind {
            k if self.can_afford_robot(k, bp) => 0,
            R::Ore => div_ceil(
                bp.cost_ore_ore - self.resource(R::Ore),
                self.num_robots(R::Ore),
            ) as i32,
            R::Clay => div_ceil(
                bp.cost_clay_ore - self.resource(R::Ore),
                self.num_robots(R::Ore),
            ) as i32,
            R::Obsidian if self.num_robots(R::Clay) == 0 => -1,
            R::Geode if self.num_robots(R::Obsidian) == 0 => -1,
            R::Obsidian => {
                let ore_turns = div_ceil(
                    bp.cost_obs_ore - self.resource(R::Ore),
                    self.num_robots(R::Ore),
                );
                let clay_turns = div_ceil(
                    bp.cost_obs_clay - self.resource(R::Clay),
                    self.num_robots(R::Clay),
                );
                max(ore_turns, clay_turns) as i32
            }
            R::Geode => {
                let ore_turns = div_ceil(
                    bp.cost_geode_ore - self.resource(R::Ore),
                    self.num_robots(R::Ore),
                );
                let obs_turns = div_ceil(
                    bp.cost_geode_obs - self.resource(R::Obsidian),
                    self.num_robots(R::Obsidian),
                );
                max(ore_turns, obs_turns) as i32
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

    pub fn collect(&self, n: u32) -> State {
        let one_collect = ((self.state >> 32) & 0xFFFFFFFF) as u64;
        let collection = one_collect * n as u64;
        State {
            state: self.state + collection,
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

fn find_max(bp: &Blueprint, state: State, turns: u32, max_so_far: u32) -> u32 {
    if turns == 0 {
        return state.resource(R::Geode);
    }
    if state.can_afford_robot(R::Geode, &bp) {
        let s = state.collect(1).buy_robot(R::Geode, &bp);
        return find_max(bp, s, turns - 1, max_so_far);
    }
    if should_early_out(state, turns, max_so_far) {
        return 0;
    }
    let mut mx = max_so_far;
    for kind in [R::Geode, R::Obsidian, R::Clay, R::Ore] {
        // Don't bother making more ore/clay robots than the max ore/clay cost of a robot
        if let R::Ore = kind {
            if state.num_robots(R::Ore) >= bp.max_ore_cost() {
                continue;
            }
        }
        if let R::Clay = kind {
            if state.num_robots(R::Clay) >= bp.cost_obs_clay {
                continue;
            }
        }

        let turns_needed = state.turns_to_buy_robot(kind, bp);
        if turns_needed < 0 {
            continue;
        }
        if turns_needed as u32 >= (turns - 1) {
            continue; // We consider waiting below
        }

        // Collect for turns_needed turns
        // Then buy this robot
        let mut s = state;
        s = s.collect(turns_needed as u32 + 1);
        s = s.buy_robot(kind, bp);
        let score = find_max(bp, s, (turns - turns_needed as u32) - 1, mx);
        mx = max(mx, score);
    }
    // Finally, consider waiting for the remainder of time
    let mut s = state;
    s = s.collect(turns);
    mx = max(mx, s.resource(R::Geode));
    return mx;
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
        // println!("Blueprint {}:", bp.num);
        let max = find_max(&bp, State::new(), 24, 0);
        let quality = bp.num * max;
        sum += quality;
        // println!("Blueprint[{}]: max: {}, quality {}", bp.num, max, quality);
    }
    println!("Part 1: {}", sum);
}

pub fn part2() {
    let blueprints = load_blueprints();
    let mut product = 1;
    for bp in &blueprints[0..3] {
        println!("Blueprint {}:", bp.num);
        let max = find_max(&bp, State::new(), 32, 0);
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
        s = s.collect(1);
        assert_eq!(1, s.resource(R::Ore));
        assert_eq!(0, s.resource(R::Clay));
        assert_eq!(0, s.resource(R::Obsidian));
        assert_eq!(0, s.resource(R::Geode));
        s = s.add_robot(R::Clay);
        s = s.collect(1);
        assert_eq!(1, s.resource(R::Clay));
        assert_eq!(0, s.resource(R::Obsidian));
        assert_eq!(0, s.resource(R::Geode));
        s = s.collect(2);
        assert_eq!(3, s.resource(R::Clay));
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
