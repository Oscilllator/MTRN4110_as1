#include <winSock.h>

#include <windows.h> 
#include <iostream> 
#include <conio.h>
#include <thread>
#include <string>
#include <future>



#define MY_MESSAGE_NOTIFICATION      1048 //Custom notification message
HWND hwnd;
//using namespace std;
SOCKET ss; //Server
SOCKET ClientSock; //Client ID on Server Side

#define DEFAULT_BUFLEN 512

char recvbuf[DEFAULT_BUFLEN];
int recvbuflen = DEFAULT_BUFLEN;



void CloseConnection(SOCKET ks) {
	if (ks) {
		closesocket(ks);
	}
	WSACleanup();
}
/*

bool ConnectToHost(int PortNo, char* IPAddress) {
	CloseConnection(ss);
	SOCKET ss;
	WSAData wsadata;
	

	int error = WSAStartup(0x0202, &wsadata);

	if (error)
		return false;

	if (wsadata.wVersion != 0x0202) {
		WSACleanup();
		return false;
	} //if wrong version stop 

	SOCKADDR_IN target; //object with the target Server information

	target.sin_family = AF_INET;
	target.sin_port = htons(PortNo);
	target.sin_addr.s_addr = inet_addr(IPAddress);

	s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP); //intialise socket

	if (s == INVALID_SOCKET) {
		return false;
	} //check the socket is created

	//Now we actually try to connect
	if (connect(s, (SOCKADDR *)&target, sizeof(target)) == SOCKET_ERROR) {
	return false;
	} else {
		return true;
	}
	//now we should be connected;
}
*/
int ListenOnPort(int portno)
{
	
	WSADATA w;
	int error = WSAStartup(0x0202, &w);   // Fill in WSA info

	if (error)
	{
		std::cout << "winsock error" << std::endl;
		return false; //For some reason we couldn't start Winsock

	}

	if (w.wVersion != 0x0202) //Wrong Winsock version?
	{
		WSACleanup();
		std::cout << "wrong version of winsock" << std::endl; 
		return false;
	}

	SOCKADDR_IN addr; // The address structure for a TCP socket

	addr.sin_family = AF_INET;      // Address family
	addr.sin_port = htons(portno);   // Assign port to this socket

									 //Accept a connection from any IP using INADDR_ANY
									 //You could pass inet_addr("0.0.0.0") instead to accomplish the 
									 //same thing. If you want only to watch for a connection from a 
									 //specific IP, specify that //instead.
	addr.sin_addr.s_addr = htonl(INADDR_ANY);

	ss = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP); // Create socket

	if (ss == INVALID_SOCKET)
	{
		std::cout << "invalid socket" <<std::endl; 
		return false; //Don't continue if we couldn't create a //socket!!
	}
	//u_long iMode = 1;
	//ioctlsocket(ss, FIONBIO, &iMode);


	if (bind(ss, (LPSOCKADDR)&addr, sizeof(addr)) == SOCKET_ERROR)
	{
		//We couldn't bind (this will happen if you try to bind to the same  
		//socket more than once)
		std::cout << "bind" << std::endl;
		return false;
	}

	//Now we can start listening (allowing as many connections as possible to  
	//be made at the same time using SOMAXCONN). You could specify any 
	//integer value equal to or lesser than SOMAXCONN instead for custom 
	//purposes). The function will not //return until a connection request is 
	//made
	return listen(ss, SOMAXCONN);
	
	
	//Don't forget to clean up with CloseConnection()!
}

void acceptThread() {
	//CloseConnection(ClientSock);
	ClientSock = INVALID_SOCKET;
	ClientSock = accept(ss, NULL, NULL);
}


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

void sendingLoop(int freq) {
	//int freq = 25;
	unsigned short int measurements[10] = { 0 };
	int counter = 0;
	bool state = 1;
	while (1) {
	
		freq = string2int(recvbuf);
		if (freq == 0) break;

		if (freq > 50) freq = 50;

		Sleep(1000 / freq);

		if (measurements[0] == 0 || measurements[0] == 200) state = !state;

		for (int i = 0; i < 10; i++) {
			if (state) measurements[i]--;
			else measurements[i]++;

			std::cout << measurements[i] << '\t';
		}

		std::cout << '\n';

		send(ClientSock, (char *)&measurements, 20, 0);
	
	
	}

}

int main() {
	std::cout << "Press any key to start the Server:" << std::endl;
	if (_getch()) {
		if (ListenOnPort(15000) != 0) {
			std::cout << "listen on port failed" << std::endl;
		}
		else {
			std::cout << "Server started" << std::endl;
		}
	}

	std::thread Accept(acceptThread);

	Accept.join();
	std::cout<< "connection joined" << std::endl;
	
	ClientSock = INVALID_SOCKET;
	while (accept(ss, NULL, NULL) == INVALID_SOCKET) {
		ClientSock == accept(ss, NULL, NULL);
	}
	
	if (ClientSock == INVALID_SOCKET) {
		std::cout << "Bad Socket" << std::endl;
	}

	
	//if (recv(ClientSock, recvbuf, sizeof(recvbuf), 0) != 0) {
	//	std::cout << "received frequency: " << recvbuf << std::endl;
	//}
	Sleep(100);

	int freq = 25;
	
	//unsigned short int* measurements = new unsigned short int[10];
	unsigned short int measurements[10] = { 0 };
	int counter = 0;
	bool state = 1; 

	while (1) {
		std::cout << "Running Server Loop" << std::endl;
		
		recv(ClientSock, recvbuf, sizeof(recvbuf), 0);
		freq = string2int(recvbuf);
		if (freq == 0) break;

		if (freq > 50) freq = 50;

		Sleep(1000 / freq);

		if (measurements[0] == 0 || measurements[0] == 200) state = !state;

		for (int i = 0; i < 10; i++) {
			if (state) measurements[i]--;
			else measurements[i]++;
			
			std::cout << measurements[i] << '\t';
		}

		std::cout << '\n';
		
		send(ClientSock, (char *)&measurements, 20, 0);
	}
	
	return 0;
}