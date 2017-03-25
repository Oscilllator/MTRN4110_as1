#include "EthernetClient.h"
#include <iostream>
#include <ctime>



int string2int(char stringNumber[]) {
	// 1.
	if (!stringNumber) {
		printf("Parameter error\n");
		return NULL;
	}
	char numberSign = stringNumber[0];
	bool isPositive = true;
	int number = 0;
	int i = 0;

	// 2.
	if (numberSign < '0') {
		if (numberSign == '-') {
			isPositive = false;
			i++;
		}
		else {
			printf("Number sign error: '%c'\n", numberSign);
			return NULL;
		}
	}

	// 3.
	int stringLength = strlen(stringNumber);

	while (i < stringLength) {
		int digit = stringNumber[i++] - '0';
		if (digit < 0 || digit > 9) {
			printf("Invalid character '%c' on the position '%d'\n", stringNumber[i - 1], (i - 1));
			return NULL;
		}
		number *= 10;
		number += digit;
	}

	// 4.
	if (isPositive) {
		return number;
	}
	else {
		return -number;
	}
}


int main() {
	char* IP = "127.0.0.1";
	char* portsend = "15005";
	char* portrecv = "15000";
	
	//EthernetClient clients(IP, portsend);
	EthernetClient clientr(IP, portrecv);
	//clients.ConnectToServer();
	clientr.ConnectToServer();

	char* sender = new char[1];
	std::cout << "Set Speed in Hertz" << std::endl;
	
	//std::cin >> sender;
	//int freq = string2int(sender);
	//client.SendData(sender, sizeof(sender));

	//std::cout << freq << std::endl;
	unsigned short int received[20] = { 0 };
	time_t tstart, tend;
	tstart = time(0);
	int freq = 5;
	while (1) {
		tend = time(0);
		/*
		if (difftime(tend, tstart) == 10) {
			freq = 10;
			clients.SendData("10", 2);
		}
		if (difftime(tend, tstart) == 20) {
			freq = 20;
			clients.SendData("10", 2);
		}
		if (GetKeyState(27) != 0) {
			clients.SendData("0", 1);
			break;
		}
		else {
			//std::cin >> freq;
		}
		*/
		Sleep(1000/freq);
		
		clientr.ReceiveData();
		std::cout << "Received Measurements: " << std::endl;

		

		for (int i = 0; i < 20; i = i + 2) {
			std::cout << static_cast<unsigned short int>(clientr.RxData[i]) << '\t';
		}

		std::cout << '\n';
	}
	
	//clients.CloseConnection();
	clientr.CloseConnection();
	return 0; 

}