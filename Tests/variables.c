int a;

extern int printd( int i );

int test(int z,int w,int y) {
  printd(z);
}

int main(int z) {
  int a;
  a = printd(1);
  return 3;
}
