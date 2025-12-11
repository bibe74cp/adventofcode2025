#!/bin/sh
#
# docker-cp.sh - Copy sample and input files into the docker container
#
# Generate this file's content with the following script:
#
# for d in $(seq 1 12); do dd=$(echo "0$d" |sed -E 's/.*(..)/\1/'); echo "[ -f day$dd/sample.txt ] && docker cp day$dd/sample.txt sql2025:/var/aoc/sample_D${dd}P1.txt"; echo "[ -f day$dd/input.txt ] && docker cp day$dd/input.txt sql2025:/var/aoc/input_D${dd}P1.txt"; done
#
[ -f day01/sample.txt ] && docker cp day01/sample.txt sql2025:/var/aoc/sample_D01P1.txt
[ -f day01/input.txt ] && docker cp day01/input.txt sql2025:/var/aoc/input_D01P1.txt
[ -f day02/sample.txt ] && docker cp day02/sample.txt sql2025:/var/aoc/sample_D02P1.txt
[ -f day02/input.txt ] && docker cp day02/input.txt sql2025:/var/aoc/input_D02P1.txt
[ -f day03/sample.txt ] && docker cp day03/sample.txt sql2025:/var/aoc/sample_D03P1.txt
[ -f day03/input.txt ] && docker cp day03/input.txt sql2025:/var/aoc/input_D03P1.txt
[ -f day04/sample.txt ] && docker cp day04/sample.txt sql2025:/var/aoc/sample_D04P1.txt
[ -f day04/input.txt ] && docker cp day04/input.txt sql2025:/var/aoc/input_D04P1.txt
[ -f day05/sample.txt ] && docker cp day05/sample.txt sql2025:/var/aoc/sample_D05P1.txt
[ -f day05/input.txt ] && docker cp day05/input.txt sql2025:/var/aoc/input_D05P1.txt
[ -f day06/sample.txt ] && docker cp day06/sample.txt sql2025:/var/aoc/sample_D06P1.txt
[ -f day06/input.txt ] && docker cp day06/input.txt sql2025:/var/aoc/input_D06P1.txt
[ -f day07/sample.txt ] && docker cp day07/sample.txt sql2025:/var/aoc/sample_D07P1.txt
[ -f day07/input.txt ] && docker cp day07/input.txt sql2025:/var/aoc/input_D07P1.txt
[ -f day08/sample.txt ] && docker cp day08/sample.txt sql2025:/var/aoc/sample_D08P1.txt
[ -f day08/input.txt ] && docker cp day08/input.txt sql2025:/var/aoc/input_D08P1.txt
[ -f day09/sample.txt ] && docker cp day09/sample.txt sql2025:/var/aoc/sample_D09P1.txt
[ -f day09/input.txt ] && docker cp day09/input.txt sql2025:/var/aoc/input_D09P1.txt
[ -f day10/sample.txt ] && docker cp day10/sample.txt sql2025:/var/aoc/sample_D10P1.txt
[ -f day10/input.txt ] && docker cp day10/input.txt sql2025:/var/aoc/input_D10P1.txt
[ -f day11/sample.txt ] && docker cp day11/sample.txt sql2025:/var/aoc/sample_D11P1.txt
[ -f day11/input.txt ] && docker cp day11/input.txt sql2025:/var/aoc/input_D11P1.txt
[ -f day12/sample.txt ] && docker cp day12/sample.txt sql2025:/var/aoc/sample_D12P1.txt
[ -f day12/input.txt ] && docker cp day12/input.txt sql2025:/var/aoc/input_D12P1.txt

[ -f day08/input_davide.txt ] && docker cp day08/input_davide.txt sql2025:/var/aoc/input_D08P1_davide.txt
[ -f day08/input_moreno.txt ] && docker cp day08/input_moreno.txt sql2025:/var/aoc/input_D08P1_moreno.txt
[ -f day08/input_emanuele.txt ] && docker cp day08/input_emanuele.txt sql2025:/var/aoc/input_D08P1_emanuele.txt
[ -f day08/input_mirko.txt ] && docker cp day08/input_mirko.txt sql2025:/var/aoc/input_D08P1_mirko.txt
[ -f day08/input_luca.txt ] && docker cp day08/input_luca.txt sql2025:/var/aoc/input_D08P1_luca.txt

[ -f day11/sample2.txt ] && docker cp day11/sample2.txt sql2025:/var/aoc/sample_D11P2.txt
