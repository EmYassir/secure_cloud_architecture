#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#define MIN_HOST 4
#define MAX_HOST 8

using namespace std;

void connectHostUseSsh(int idHost, const string &commandVM, const string &idJob, const string &userName);
int parseParameter(int argc, char* argv[]);
string getCurrentDirectory();
vector<string> getAllArchivesName(const string &dirPath);
void copyArchivesToDestinationTempFolder(const string &fileName, const string &location);
void copyAllArchivesToDestination();
string getIdJob(const string &fileName);
string getUserName(const string &fileName);
string getNom(const string &fileName);
void launchAllJobs();

string convertInt(int number)
{
   stringstream ss;//create a stringstream
   ss << number;//add number to the stream
   return ss.str();//return a string with the contents of the stream
}

int randomHost(int min, int max)
{
	int randNum = min+(rand()%(int)(max-min+1));
	return randNum;
}

void displayVectorContent(const vector<string> &list) {
	cout << "ALL FILE IN CURRENT DIRECTORY:\n"<< endl;
	for (vector<string>::const_iterator i = list.begin(); i!=list.end(); ++i) {
		cout << *i << "\n" <<endl;
	}
}


