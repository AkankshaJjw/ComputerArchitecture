#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stddef.h>
#include <stdbool.h> 

#define WIDTH 512
#define HEIGHT 512
#define DEPTH 255
#define MAX 8
typedef char* image_type;
bool always = true;


//static const unsigned MAX = 8;
void *digitizer();    //Function prototype
void *tracker();     //Function prototype
void *grab(image_type dig_image); //should grab lenna image
void *analyze(image_type track_image); //rotate image by 90 degrees

pthread_cond_t buf_notfull = PTHREAD_COND_INITIALIZER;
pthread_cond_t buf_notempty = PTHREAD_COND_INITIALIZER;

/* For safe condition variable usage, must use a boolean predicate and  */
/* a mutex with the condition.                                          */
//int bufavail = 0;
int bufavail = MAX;
image_type frame_buf[MAX];
pthread_mutex_t buflock= PTHREAD_MUTEX_INITIALIZER;

int main()
{
     pthread_t thread1, thread2;
    /* Create independent threads each of which will execute function */
     pthread_create (&thread1, NULL, digitizer, NULL);
     pthread_create (&thread2, NULL, tracker, NULL);

     /* Wait till threads are complete before main continues. Unless we  */
     /* wait we run the risk of executing an exit which will terminate   */
     /* the process and all threads before the threads have completed.   */

     pthread_join( thread1, NULL);
     pthread_join( thread2, NULL); 
     
     exit(0);
}

void* digitizer() {
  image_type dig_image;
  int tail = 0;
  while(true) {
    grab(dig_image);
    pthread_mutex_lock(&buflock);
    if (bufavail == 0) 
        pthread_cond_wait(&buf_notfull, &buflock);
    pthread_mutex_unlock(&buflock);
    frame_buf[tail % MAX] = dig_image;
    tail = tail + 1;
    pthread_mutex_lock(&buflock);
    bufavail = bufavail - 1;
    pthread_cond_signal(&buf_notempty);
    pthread_mutex_unlock(&buflock);
  } 
}

void* tracker() {
  image_type track_image;
  int head = 0;
  while(always == true) { 
    pthread_mutex_lock(&buflock);
    if (bufavail == MAX) 
        pthread_cond_wait(&buf_notempty, &buflock);
    pthread_mutex_unlock(&buflock);
    track_image = frame_buf[head % MAX];
    head = head + 1;
    pthread_mutex_lock(&buflock);
    bufavail = bufavail + 1;
    pthread_cond_signal(&buf_notfull);
    pthread_mutex_unlock(&buflock);
    analyze(track_image);
  } 
}

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
  for (i = 0; i < HEIGHT; ++i) {
    fwrite(&pixels[i*WIDTH], sizeof(char), WIDTH, outfile);
  }
  fclose(outfile);
  free(pixels);
}

// int main(void)
// {
//   char *lenna;

//   lenna = read();
//   write(lenna);
//   return 0;
// }
void* grab(image_type dig_image) {
    // read Lenna image
    char* lenna = read();
}

void* analyze(image_type track_image) {
    //rotate image by 90 degrees
    char* lenna;
    write(lenna);
}