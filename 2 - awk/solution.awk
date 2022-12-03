BEGIN {
    r = 1
    p = 2
    s = 3
}
/. X/ { outcome = 0 }
/. Y/ { outcome = 3 }
/. Z/ { outcome = 6 }

/A X/ { choice = s }
/A Y/ { choice = r }
/A Z/ { choice = p }

/B X/ { choice = r }
/B Y/ { choice = p }
/B Z/ { choice = s }

/C X/ { choice = p }
/C Y/ { choice = s }
/C Z/ { choice = r }
{
    round_score = outcome + choice
    total_score += round_score
}
END {
    print total_score
}