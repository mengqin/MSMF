#include <stdio.h>

#define TEST_SEG __attribute__((section (".test_seg.all")))

TEST_SEG int test_var = 1;

extern long __test_seg_begin;
extern long __test_seg_end;

int main()
{
	printf("%p\n", &test_var);
	printf("%p\n", &__test_seg_begin);
	printf("%p\n", &__test_seg_end);

	return 0;
}
