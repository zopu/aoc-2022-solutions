#include <stdio.h>
#include <stdlib.h>

#define CHAR_BUF_SIZE 14

void read_input_file(char *file_path, char (*table)[150], int *size_x, int *size_y) {
  FILE *fptr;
  fptr = fopen(file_path, "r");

  char *buffer;
  size_t bufsize = 200; // Lines look big
  int linelen;

  buffer = (char *)malloc(bufsize * sizeof(char));
  int linecount = 0;
  while ((linelen = getline(&buffer, &bufsize, fptr)) > 0)
  {
    for (int i = 0; i < linelen - 1; ++i) {
      table[i][linecount] = buffer[i];
    }
    ++linecount;
    if ((linelen - 1) > *size_x) *size_x = linelen - 1;
  }
  *size_y = linecount;
}

// 0 if something is found as tall as height otherwise 1
int check_up(int height, char (*table)[150], int x, int y) {
  if (table[x][y] >= height) return 0;  
  if (y == 0) return 1;
  return check_up(height, table, x, y - 1);
}

// 0 if something is found as tall as height otherwise 1
int check_left(int height, char (*table)[150], int x, int y) {
  if (table[x][y] >= height) return 0;  
  if (x == 0) return 1;
  return check_left(height, table, x - 1, y);
}

// 0 if something is found as tall as height otherwise 1
int check_down(int height, char (*table)[150], int x, int y, int size_y) {
  if (table[x][y] >= height) return 0;  
  if (y == size_y - 1) return 1;
  return check_down(height, table, x, y + 1, size_y);
}

// 0 if something is found as tall as height otherwise 1
int check_right(int height, char (*table)[150], int x, int y, int size_x) {
  if (table[x][y] >= height) return 0;  
  if (x == size_x - 1) return 1;
  return check_right(height, table, x + 1, y, size_x);
}

int is_visible(char (*table)[150], int size_x, int size_y, int x, int y) {
  if (x == 0 || y == 0 || x == (size_x - 1) || y == (size_y - 1)) {
    return 1;
  }

  if (check_up(table[x][y], table, x, y - 1)) return 1;
  if (check_left(table[x][y], table, x - 1, y)) return 1;
  if (check_down(table[x][y], table, x, y + 1, size_y)) return 1;
  if (check_right(table[x][y], table, x + 1, y, size_x)) return 1;
  
  return 0;
}

int main(int argc, char **argv)
{
  char table[150][150];
  int size_x = 0;
  int size_y = 0;
  read_input_file(argv[1], table, &size_x, &size_y);
  printf("Got table size %d,%d\n", size_x, size_y);
  int sum = 0;
  for (int i = 0; i < size_x; ++i) {
    for (int j = 0; j < size_y; ++j) {
      if (is_visible(table, size_x, size_y, i, j)) {
        ++sum;
      }
    }
  }
  printf("Visible trees: %d\n", sum);
}