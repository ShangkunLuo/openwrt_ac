#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <unistd.h>


#define MAXLINE 4096
int main(int argc, char **argv)
{
	int sockfd;
	struct sockaddr_in servaddr, cliaddr;
	int n;
	int len;
	char mesg[MAXLINE];

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);

	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family      = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port        = htons(9877);

	bind(sockfd, (struct sockaddr*) &servaddr, sizeof(servaddr));
        //deamon
        pid_t pid, sid;
        pid = fork();
        if (pid < 0)
                exit(EXIT_FAILURE);
        if (pid > 0)
                exit(EXIT_SUCCESS);

        sid = setsid();
        if (sid < 0) {
                fprintf(stderr,"setsid() returned error\n");
                exit(EXIT_FAILURE);
        }

        char *directory = ".";
        if ((chdir(directory)) < 0) {
            fprintf(stderr,"chdir() returned error\n");
            exit(EXIT_FAILURE);
        }

        close(STDIN_FILENO);
        close(STDOUT_FILENO);
        close(STDERR_FILENO);

	//dg_echo(sockfd, (SA *) &cliaddr, sizeof(cliaddr));
	while(1)
	{
		len=sizeof(cliaddr);
		memset(mesg,0,MAXLINE);
		n=recvfrom(sockfd,mesg,MAXLINE,0, (struct sockaddr*) &cliaddr,&len);
		printf("recv=%s",mesg);
		memset(mesg,0,MAXLINE);
		stpcpy(mesg,"OK\n");
		sendto(sockfd,mesg,n,0, (struct sockaddr*) &cliaddr,len);
		
		
	}
        return 0;	
}
