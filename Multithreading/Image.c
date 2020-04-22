#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#define WIDTH 512
#define HEIGHT 512
#define DEPTH 255

char *read(void)
{
  FILE *infile;			/* lenna image */
  char *pixels;			/* image to populate */
  size_t i;

  infile = fopen("lena512.pgm", "r");
  /* skip magic number, comment, width, height, and depth */
  for (i = 0; i < 4; ++i)
    fscanf(infile, "%*[^\n]\n");
  pixels = (char *)malloc(WIDTH * HEIGHT * sizeof(char));
  /* read each row of image */
  for (i = 0; i < HEIGHT; ++i) {
    fread(&pixels[i*WIDTH], sizeof(char), WIDTH, infile);
  }
  fclose(infile);
  return pixels;
}

void write(char *pixels)
{
  FILE *outfile;
  size_t i;

  outfile = fopen("rotated.pgm", "w");
  fputs("P5\n", outfile);	/* magic number for a binary pgm */
  /* the width, height, and depth of the image */
  fprintf(outfile, "%d %d\n%d\n", WIDTH, HEIGHT, DEPTH);
  /* now write each row */
  for (int i = 0; i < WIDTH; i++) 
        for (int j = 0, k = WIDTH - 1; j < k; j++, k--) 
            swap(pixel[j][i], pixel[k][i]);
  for (int i = 0; i < HEIGHT; i++) 
        for (int j = i; j < WIDTH; j++) 
            swap(arr[i][j], arr[j][i]);
  for (i = 0; i < HEIGHT; ++i) {
    fwrite(&pixels[i*WIDTH], sizeof(char), WIDTH, outfile);
  }
  fclose(outfile);
  free(pixels);
}

int main(void)
{
  char *lenna;

  lenna = read();
  write(lenna);
  return 0;
}
