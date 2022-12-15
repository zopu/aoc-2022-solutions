import java.io.File;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class App {

    static Pair<Pair<Integer>> parseLine(String line) {
        Pattern pattern = Pattern.compile("[-0-9]+");
        Matcher matcher = pattern.matcher(line);
        matcher.find();
        var a = Integer.parseInt(matcher.group(0));
        matcher.find();
        var b = Integer.parseInt(matcher.group(0));
        matcher.find();
        var c = Integer.parseInt(matcher.group(0));
        matcher.find();
        var d = Integer.parseInt(matcher.group(0));
        return new Pair<>(new Pair<>(a, b), new Pair<>(c, d));
    }

    // Check if this box is entirely eliminated by any of the beacon/sensor pairs
    static boolean eliminateBox(ArrayList<Pair<Pair<Integer>>> coords,
            int min_x, int max_x, int min_y, int max_y) {
        for (var sb : coords) {
            var s = sb.x;
            var b = sb.y;
            var d_sb = Math.abs(s.x - b.x) + Math.abs(s.y - b.y);
            var d_tl = Math.abs(s.x - min_x) + Math.abs(s.y - min_y);
            var d_tr = Math.abs(s.x - max_x) + Math.abs(s.y - min_y);
            var d_bl = Math.abs(s.x - min_x) + Math.abs(s.y - max_y);
            var d_br = Math.abs(s.x - max_x) + Math.abs(s.y - max_y);
            if ((d_tl <= d_sb) && (d_tr <= d_sb) && (d_bl <= d_sb) && (d_br <= d_sb)) {
                return true;
            }
        }
        return false;
    }

    static boolean quadCheck(
            ArrayList<Pair<Pair<Integer>>> coords,
            int min_x, int max_x, int min_y, int max_y) {
        int w = max_x - min_x;
        int h = max_y - min_y;
        int half_x = min_x + (int) Math.floor(w / 2);
        int half_y = min_y + (int) Math.floor(h / 2);

        if (eliminateBox(coords, min_x, max_x, min_y, max_y)) {
            return false;
        }

        if (w == 0 && h == 0) {
            long result = (((long) min_x) * (long) 4000000) + min_y;
            System.out.println("Part 2: " + result);
            return true;
        }

        // Check top-left, top-right, bottom-left, bottom-right
        if (quadCheck(coords, min_x, half_x, min_y, half_y)) {
            return true;
        }
        if (w > 0 && quadCheck(coords, half_x + 1, max_x, min_y, half_y)) {
            return true;
        }
        if (h > 0 && quadCheck(coords, min_x, half_x, half_y + 1, max_y)) {
            return true;
        }
        if (w > 0 && h > 0 && quadCheck(coords, half_x + 1, max_x, half_y + 1, max_y)) {
            return true;
        }
        return false;
    }

    public static void main(String[] args) throws Exception {
        final String INPUT_FILE = "input.txt";
        final int ROW = 2000000;
        var lines = Files.readAllLines(new File(INPUT_FILE).toPath(), Charset.defaultCharset());

        ArrayList<Pair<Pair<Integer>>> coords = new ArrayList<>(
                lines.stream()
                        .map(l -> parseLine(l))
                        .collect(Collectors.toList()));

        // Get the max/min x we have to check
        int max_x = 0;
        int min_x = Integer.MAX_VALUE;
        for (var line : coords) {
            var s = line.x;
            var b = line.y;
            var d = Math.abs(s.x - b.x) + Math.abs(s.y - b.y);
            if (s.x + d > max_x) {
                max_x = s.x + d;
            }
            if (s.x - d < min_x) {
                min_x = s.x - d;
            }
        }
        System.out.println("Max x: " + max_x);

        // Now check every position on the row
        int count_safe = 0; // "safe" means definitely no beacon
        rowloop: for (int i = min_x - 1; i <= max_x; ++i) {
            for (var sb : coords) {
                var s = sb.x;
                var b = sb.y;
                if (b.y == ROW && b.x == i) {
                    continue rowloop;
                }
                var d_sb = Math.abs(s.x - b.x) + Math.abs(s.y - b.y);
                var d_si = Math.abs(s.x - i) + Math.abs(s.y - ROW);
                if (d_si <= d_sb) {
                    ++count_safe;
                    continue rowloop;
                }
            }
        }
        System.out.println("Part 1: " + count_safe);

        quadCheck(coords, 0, 4000000, 0, 4000000);
    }
}
