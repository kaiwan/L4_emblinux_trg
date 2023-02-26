#include <stdio.h>
#include <unistd.h>
int main()
{
	printf("PID: %d\n", getpid());
	for (;;) {
		printf("Hello, world\n");
		printf("Hello, world\n");
		printf("Hello, world\n");
		sleep(.1);
	}
}
