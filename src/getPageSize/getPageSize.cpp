#include <iostream>
using std::cout;
using std::endl;
#include <unistd.h>

int main() {
	cout << getpagesize() << endl;
} //main()
