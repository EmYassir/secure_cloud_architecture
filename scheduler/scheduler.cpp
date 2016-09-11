#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <cstring>
#include <limits.h>
#include <unistd.h>

#include <sys/types.h>
#include <dirent.h>
#include <errno.h>
#include <vector>
#include <map>

#include "scheduler.h"
using namespace std;
string copyCmd = "scp ";
map<string,int> hostJob; // idJob-idHost

char buf[256];
char str[256];
int idHost;
int idJob;
string userGroup;

// Command form: ./scheduler
int main(int argc, char* argv[]) {

	/***********************
	 * Principle task
	 ***********************/
	srand(time(NULL));
	parseParameter(argc, argv);
	copyAllArchivesToDestination();

	/****************
	 * END
	 ****************/
	return 1;
}

void connectHostUseSsh(int idHost, const string &commandVM, const string &idJob, const string &userName) {
	cout<<"Connection to 10.0.0."<< idHost << " IdJob:" << idJob <<endl;
	string command = "ssh -f root@10.0.0."+convertInt(idHost)+" '"+commandVM+" "+idJob+" "+userName+
"'";
	cout <<command<<endl;
	system(command.c_str());
}

void copyAllArchivesToDestination() {
	cout << "Starting copy all file from to_schedule to each host" <<endl;
	string toScheduler = "/to_schedule/";
	vector<string> allArchives = getAllArchivesName(toScheduler);
	for (vector<string>::const_iterator i = allArchives.begin(); i!= allArchives.end(); ++i) {
		string fileName = *i;
		string tempsLocation = "/tmp/";
		copyArchivesToDestinationTempFolder(fileName,tempsLocation);
	}
}

string getNom(const string &fileName) {
        int found = fileName.find(".tar.gz");
        return fileName.substr(0,found);        
}

void copyArchivesToDestinationTempFolder(const string &fileName, const string &location) {
	idHost = randomHost(MIN_HOST, MAX_HOST);
	string idJob = getIdJob(fileName);
	hostJob.insert(std::pair<string,int>(idJob,idHost)); // Save the location of host where the job will be executed
	cout << "Copy job:" <<idJob<<" to host 10.0.0." << idHost <<endl;

	string scpCmd = "scp /to_schedule/"+fileName+" root@10.0.0."+convertInt(idHost)+":"+location;
	system(scpCmd.c_str());

	string cmdk = "mkdir /tmp/"+getUserName(fileName)+"_"+getIdJob(fileName);
	string cmd = "ssh -f root@10.0.0."+convertInt(idHost)+ " '"+cmdk+"'";
	system(cmd.c_str());

	cmd = "mv /to_schedule/"+fileName+" /history/";
	system(cmd.c_str());
	connectHostUseSsh(idHost, "demarre.sh",getNom(fileName), getUserName(fileName));

}


int parseParameter(int argc, char* argv[]) {
}


string getNameUser(const vector<string> archives, const string &idJob) {
	string temp = "";
	for (vector<string>::const_iterator it = archives.begin(); it!= archives.end(); ++it) {
		if (getIdJob(*it).compare(idJob)) {
			temp = getUserName(*it);
		}
	}
	return temp;
}

void launchAllJobs() {
	vector<string> archives = getAllArchivesName("/to_schedule/");
	for (map<string,int>::const_iterator it = hostJob.begin(); it!= hostJob.end(); it++) {
		string idJob = (*it).first;
		int idHost = (*it).second;
		connectHostUseSsh(idHost, "demarre.sh", idJob, "sge");

	}
}

string getIdJob(const string &fileName) {
	size_t last_underline = fileName.find_last_of("_");
	if (last_underline==-1) {
		cout<<"Erreur archive name." << "_ NOT FOUND idJob" << endl;
		return string("NULL");
	}
	string sb = fileName.substr(last_underline,fileName.length());
	return sb.substr(1,sb.length()-8);
}

string getUserName(const string &fileName) {
	size_t first_underline = fileName.find_first_of("_");
	if (first_underline==-1) {
                cout<<"Erreur archive name." << "_ NOT FOUND Username" << endl;
		return string("NULL");
        }
	return fileName.substr(0,first_underline);
}

std::string getCurrentDirectory() {
	char result[ PATH_MAX ];
	ssize_t count = readlink( "/proc/self/exe", result, PATH_MAX );
	std::string proName = std::string( result, (count > 0) ? count : 0 );
	size_t lastSlash = proName.find_last_of("\\/");
	return proName.substr(0,lastSlash)+"/"; 
}

vector<string> getAllArchivesName(const string &dirPath) {
	vector<string> archives = vector<string>();
	DIR *dp;
	struct dirent *drnt;
	dp = opendir(dirPath.c_str());
	if (dp == NULL) {
		cout << "Error(" << errno << ") opening" << dirPath << endl;
	} else {
		while ((drnt=readdir(dp)) != NULL) {
			string temp = drnt->d_name;
			if (temp.find("tar")!=-1) {
				archives.push_back(drnt->d_name);
			}
		}
		closedir(dp);
	}
	return archives;
}
