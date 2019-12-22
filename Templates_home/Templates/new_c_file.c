#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void)
{
	int i =  3;
	for(i = 0; i < 5; ++i)
		printf("3 << %d = %d\n",i,  (3 << i));
	return 0;
}
